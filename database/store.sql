-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
use dbshop;
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-07-2021 a las 05:06:04
-- Versión del servidor: 10.4.18-MariaDB
-- Versión de PHP: 7.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `store`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE PROCEDURE `addCarrCompra` (IN `in_cantidad` INT, IN `in_precio_compra` DECIMAL(15,2), IN `in_idProducto` INT, IN `in_idProveedor` INT, IN `in_idCaja` INT, IN `in_pro_nombre` VARCHAR(200), IN `in_cantidad_minima` INT, IN `in_codeBarra` VARCHAR(50))  begin
    declare subtotalCompra decimal(15,2);
    declare cantidad_update decimal(15,2);
    declare codigo nvarchar(19);
    IF EXISTS(select * from carrito where idProducto = in_idProducto and idPersona = in_idProveedor) THEN
        update carrito set cantidad = cantidad + in_cantidad, precio =
        in_precio_compra where idProducto = in_idProducto and idPersona = in_idProveedor;
        update product set pro_precio_compra= in_precio_compra where id_product= in_idProducto;
        select cantidad into cantidad_update from carrito where idProducto = in_idProducto;
        set subtotalCompra = cantidad_update* in_precio_compra;
        update carrito set  subTotal = subtotalCompra where idProducto = in_idProducto and idPersona = in_idProveedor;
    ELSE
        set subtotalCompra = in_cantidad* in_precio_compra;
        case
            when in_pro_nombre is null then
                insert into carrito(idProducto, idPersona, idCaja, cantidad, subTotal,precio)
                values
                (
                   in_idProducto,
                   in_idProveedor,
                   in_idCaja,
                   in_cantidad,
                   subtotalCompra,
                   in_precio_compra
                );
            else
            insert into product (pro_name, pro_precio_compra,pro_cantidad, pro_status, pro_cod_barra,fecha_creacion)
            values (in_pro_nombre,in_precio_compra,in_cantidad,'active',in_codeBarra, now());
            set in_idProducto:= LAST_INSERT_ID();
            SELECT concat('P', (LPAD(in_idProducto, 4, '0'))) into codigo;
            update product set pro_code = codigo where id_product = in_idProducto;
            insert into carrito(idProducto, idPersona, idCaja, cantidad, subTotal,precio)
            values
            (
               in_idProducto,
               in_idProveedor,
               in_idCaja,
               in_cantidad,
               subtotalCompra,
               in_precio_compra
            );
        END CASE;
     end if;
     select
      car.id,
      car.idProducto,
      car.idPersona,
      car.idCaja,
      car.cantidad,
      car.precio,
      car.subTotal,
      pro.pro_name,
      per.per_razon_social,
      totales.total
     from (
      (select sum(carrito.subTotal) as total from carrito where idPersona = in_idProveedor)
      ) totales,
     carrito as car,
     product as pro,
     persona as per
     where car.idProducto= pro.id_product and
     car.idPersona = per.id_persona and
     car.idPersona = in_idProveedor
     group by car.id,car.idProducto,car.idPersona,car.idCaja,car.cantidad,car.precio, car.subTotal,pro.pro_name, per.per_razon_social;
     end$$

CREATE PROCEDURE `addCompra` (IN `in_subtotal` DECIMAL(15,2), IN `in_total` DECIMAL(15,2), IN `in_igv` DECIMAL(15,2), IN `in_tipoComprobante` VARCHAR(20), IN `in_tipoPago` VARCHAR(20), IN `in_idProveedor` INT, IN `in_cuotas` INT, IN `in_montoPagado` DECIMAL(15,2), IN `in_montoDeudaOrVuelto` DECIMAL(15,2))  begin
    DECLARE in_idproducto int;
    DECLARE in_cantidad int;
    DECLARE in_precio int;
    DECLARE in_id_compra int;
    DECLARE in_subtotalCarr decimal(15,2);
    DECLARE in_idDetalle int;
    DECLARE  in_estadoPago int;
    DECLARE  in_max_boleta int ;
    DECLARE  in_max_factura int;
    declare in_max_id_compra int;
    DECLARE  in_sericorrelativo NVARCHAR(50);
    DECLARE  in_serieComprobante NVARCHAR(50);

    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_temp CURSOR FOR
    SELECT idProducto,cantidad,precio, subTotal from carrito WHERE carrito.idPersona=in_idProveedor;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    if in_montoPagado < in_total then
      set in_estadoPago  = 1;
    else
      set in_estadoPago = 2;
    end if;
    case in_tipoComprobante
     when 'boleta' then
     select IFNULL(max(idCompra +1), 0 +1) into in_max_boleta from compra where comTipoComprobante = 'boleta';
     SELECT concat('B', (LPAD(in_max_boleta, 6, '0'))) into in_serieComprobante;
     when 'factura' then
     select IFNULL(max(idCompra +1),0+1)  into in_max_factura from compra where comTipoComprobante = 'factura';
     SELECT concat('F', (LPAD(in_max_factura, 6, '0'))) into in_serieComprobante;
    end case;
  INSERT INTO compra(idProveedor, comFecha, comTipoComprobante, comSerieCorrelativo, comTipoPago, comUrlComprobante, comDescuento, comEstado, comSubTotal, comTotal, comIgv,
                     com_cuotas,comMontoPagado, comMontoDeuda, comSerieComprobante,comEstadoTipoPago)
  values(in_idProveedor,now(),in_tipoComprobante,null,in_tipoPago,null,null,1,in_subtotal,in_total,in_igv,in_cuotas,
         in_montoPagado,in_montoDeudaOrVuelto,in_serieComprobante,in_estadoPago);
  SET in_id_compra = LAST_INSERT_ID();
  update compra set comSerieCorrelativo = concat('C', (LPAD(in_id_compra, 6, '0'))) where idCompra = in_id_compra;
   OPEN cursor_temp;
    read_loop: LOOP
    FETCH cursor_temp INTO in_idproducto,in_cantidad,in_precio,in_subtotalCarr;
    IF done THEN
        LEAVE read_loop;
    END IF;
    insert into detalle_compra(dcCantidad, dcPrecioUnitario, dcSubTotal, idCompra, idProduct)
    values (in_cantidad, in_precio, in_subtotal,in_id_compra,in_idproducto);
    SET in_idDetalle:=LAST_INSERT_ID();
       END LOOP;
    CLOSE cursor_temp;
      IF(in_idDetalle > 0) THEN
       DELETE FROM carrito WHERE idPersona=in_idProveedor;
    end IF;
    select in_id_compra as idCompra;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `arqueo_caja`
--

CREATE TABLE `arqueo_caja` (
  `id_arqueo_caja` int(11) NOT NULL,
  `fecha_arqueo` datetime DEFAULT NULL,
  `hora_arqueo` time DEFAULT NULL,
  `id_caja` int(11) DEFAULT NULL,
  `empresa_arqueo` varchar(50) DEFAULT NULL,
  `total_monedas_arqueo` decimal(15,2) DEFAULT NULL,
  `total_billetes_arqueo` decimal(15,2) DEFAULT NULL,
  `caja_apertura_arqueo` decimal(15,2) DEFAULT NULL,
  `total_venta_arqueo` decimal(15,2) DEFAULT NULL,
  `total_corte_arqueo` decimal(15,2) DEFAULT NULL,
  `sobrantes_arqueo` decimal(15,2) DEFAULT NULL,
  `faltantes_arqueo` decimal(15,2) DEFAULT NULL,
  `observacion_arqueo` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `arqueo_caja`
--

INSERT INTO `arqueo_caja` (`id_arqueo_caja`, `fecha_arqueo`, `hora_arqueo`, `id_caja`, `empresa_arqueo`, `total_monedas_arqueo`, `total_billetes_arqueo`, `caja_apertura_arqueo`, `total_venta_arqueo`, `total_corte_arqueo`, `sobrantes_arqueo`, `faltantes_arqueo`, `observacion_arqueo`) VALUES
(1, '2021-04-11 19:48:00', '19:48:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', 'nada nena'),
(2, '2021-04-11 20:00:00', '20:00:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', 'sswwewew'),
(3, '2021-04-11 20:06:00', '20:06:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(4, '2021-04-11 20:08:00', '20:08:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(5, '2021-04-11 20:09:00', '20:09:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', 'sasasasa'),
(6, '2021-04-11 20:13:00', '20:13:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', 'ADSFGDS'),
(7, '2021-04-11 20:13:00', '20:13:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(8, '2021-04-11 20:13:00', '20:13:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(9, '2021-04-11 20:16:00', '20:16:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(10, '2021-04-11 00:00:00', '20:17:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(11, '2021-04-11 20:23:00', '20:23:00', 3, '', '2.00', '400.00', '50.23', '452.00', '452.00', '0.00', '0.00', ''),
(12, '2021-04-12 08:22:00', '08:22:00', 3, '', '21.00', '2500.00', '50.00', '452.00', '2571.00', '0.00', '2119.00', 'falta porque emos pagado '),
(13, '2021-04-12 13:20:00', '13:20:00', 3, '', '21.00', '2500.00', '50.00', '452.00', '2571.00', '0.00', '2119.00', 'or nada'),
(14, '2021-04-13 18:53:00', '18:53:00', 3, '', '40.00', '3500.00', '300.00', '452.00', '3840.00', '0.00', '3388.00', ''),
(15, '2021-04-14 06:16:00', '06:16:00', 3, '', '98.80', '3580.00', '300.00', '969.00', '3979.00', '0.00', '3010.00', ''),
(16, '2021-04-14 06:21:00', '06:21:00', 3, '', '98.80', '3580.00', '300.00', '969.00', '3979.00', '0.00', '3010.00', 'uhhkkhkh'),
(17, '2021-04-14 06:22:00', '06:22:00', 3, '', '98.80', '3580.00', '300.00', '969.00', '3979.00', '0.00', '3010.00', 'jklñ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `id_caja` int(11) NOT NULL,
  `ca_name` varchar(250) NOT NULL,
  `ca_description` varchar(45) DEFAULT NULL,
  `ca_status` varchar(150) NOT NULL,
  `id_user` int(11) NOT NULL,
  `ca_fecha_creacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `caja`
--

INSERT INTO `caja` (`id_caja`, `ca_name`, `ca_description`, `ca_status`, `id_user`, `ca_fecha_creacion`) VALUES
(5, 'CAJAOO1', 'DSDSSD', 'active', 13, '2021-04-30 19:38:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja_corte`
--

CREATE TABLE `caja_corte` (
  `id_caja_corte` int(11) NOT NULL,
  `fecha_corte` date DEFAULT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_termino` time DEFAULT NULL,
  `id_caja` int(11) DEFAULT NULL,
  `monto_inicial` decimal(15,2) DEFAULT NULL,
  `ganancias_x_dia` decimal(15,2) DEFAULT NULL,
  `total_billetes` decimal(15,2) DEFAULT NULL,
  `total_monedas` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='''type_money : 1 monedas, 2 billetas; typecorte: 1 corte diario; 2 corto semanal'';';

--
-- Volcado de datos para la tabla `caja_corte`
--

INSERT INTO `caja_corte` (`id_caja_corte`, `fecha_corte`, `hora_inicio`, `hora_termino`, `id_caja`, `monto_inicial`, `ganancias_x_dia`, `total_billetes`, `total_monedas`) VALUES
(142, '2021-04-12', '06:05:00', '16:05:00', 3, '60.00', '805.00', '800.00', '300.30'),
(143, '2021-04-20', '07:05:00', '17:05:00', 3, '60.00', '205.00', '200.00', '5.00'),
(144, '2021-04-21', '06:08:00', '13:08:00', 3, '60.00', '880.00', '800.00', '80.00'),
(145, '2021-04-22', '09:09:00', '20:09:00', 3, '60.00', '897.90', '890.00', '7.90'),
(146, '2021-04-23', '11:09:00', '23:09:00', 3, '60.00', '890.90', '890.00', '0.90'),
(147, '2021-04-17', '08:02:00', '15:02:00', 3, '50.00', '402.00', '800.00', '200.00'),
(148, '2021-04-18', '08:18:00', '15:18:00', 3, '0.00', '402.00', '400.00', '1000.20');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja_corte_diario`
--

CREATE TABLE `caja_corte_diario` (
  `id_caja_corte_diario` int(11) NOT NULL,
  `fecha_corte_diario` datetime DEFAULT NULL,
  `id_caja_corte` int(11) DEFAULT NULL,
  `monto_entregado_dia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `caja_corte_diario`
--

INSERT INTO `caja_corte_diario` (`id_caja_corte_diario`, `fecha_corte_diario`, `id_caja_corte`, `monto_entregado_dia`) VALUES
(66, '2021-04-12 00:00:00', 142, 865),
(67, '2021-04-20 00:00:00', 143, 265),
(68, '2021-04-21 00:00:00', 144, 940),
(69, '2021-04-22 00:00:00', 145, 958),
(70, '2021-04-23 00:00:00', 146, 951),
(71, '2021-04-17 00:00:00', 147, 452),
(72, '2021-04-17 08:18:00', 148, 402);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja_corte_semanal`
--

CREATE TABLE `caja_corte_semanal` (
  `id_corte_semanal` int(11) NOT NULL,
  `ccs_monto_ingresado` int(11) DEFAULT NULL,
  `ccs_fecha_corte` datetime DEFAULT NULL,
  `css_fecha_inicio` date DEFAULT NULL,
  `css_fecha_termino` date DEFAULT NULL,
  `id_caja` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `caja_corte_semanal`
--

INSERT INTO `caja_corte_semanal` (`id_corte_semanal`, `ccs_monto_ingresado`, `ccs_fecha_corte`, `css_fecha_inicio`, `css_fecha_termino`, `id_caja`) VALUES
(39, 1207, '2021-04-17 08:18:00', '2021-04-13', '2021-04-17', 3);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja_historial`
--

CREATE TABLE `caja_historial` (
  `id_caja_historial` int(11) NOT NULL,
  `ch_fecha_operacion` datetime NOT NULL,
  `ch_tipo_operacion` varchar(150) NOT NULL,
  `ch_total_dinero` decimal(15,2) NOT NULL,
  `id_user` int(11) NOT NULL,
  `id_caja` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carrito`
--

CREATE TABLE `carrito` (
  `id` int(11) NOT NULL,
  `idProducto` int(11) DEFAULT NULL,
  `idPersona` int(11) DEFAULT NULL,
  `idCaja` int(11) DEFAULT NULL,
  `cantidad` int(50) DEFAULT NULL,
  `descuento` decimal(15,2) DEFAULT NULL,
  `subTotal` decimal(15,2) DEFAULT NULL,
  `precio` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `carrito`
--

INSERT INTO `carrito` (`id`, `idProducto`, `idPersona`, `idCaja`, `cantidad`, `descuento`, `subTotal`, `precio`) VALUES
(190, 78, 4, 1, 40, NULL, '970.00', '24.25'),
(191, 78, 3, 1, 12, NULL, '291.00', '24.25'),
(192, 82, 39, 1, 1, NULL, '24.25', '24.25'),
(196, 79, 4, 1, 1, NULL, '22.00', '22.00'),
(201, 77, 2, 1, 2, NULL, '44.00', '22.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clase_producto`
--

CREATE TABLE `clase_producto` (
  `id_clase_producto` int(11) NOT NULL,
  `clas_name` varchar(50) NOT NULL,
  `clas_id_clase_superior` int(11) NOT NULL,
  `clas_status` varchar(10) NOT NULL,
  `class_code` varchar(10) DEFAULT NULL,
  `fecha_creacion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `clase_producto`
--

INSERT INTO `clase_producto` (`id_clase_producto`, `clas_name`, `clas_id_clase_superior`, `clas_status`, `class_code`, `fecha_creacion`) VALUES
(34, 'TUBERCULOS', 0, 'active', 'CP0034', '2021-07-08'),
(35, 'BEBIDAS', 0, 'active', 'CP0035', '2021-07-12'),
(36, 'abarrotes', 0, 'active', 'CP0036', '2021-07-09'),
(37, 'Golosinas', 0, 'active', 'CP0037', '2021-07-08'),
(38, 'Nectar', 0, 'active', 'CP0038', '2021-07-08'),
(49, 'papa amarilla', 34, 'disable', 'CP0049', NULL),
(50, 'lechua', 49, 'disable', 'CP0050', NULL),
(51, 'Tanques', 0, 'active', 'CP0051', NULL),
(52, 'Mezcladoras', 0, 'active', 'CP0052', NULL),
(53, 'Accesorios', 0, 'active', 'CP0053', NULL),
(54, 'laba platos', 0, 'active', 'CP0054', NULL),
(55, 'CERAS', 0, 'active', 'CP0055', NULL),
(56, 'Tubos Tanques', 0, 'active', 'CP0056', NULL),
(57, 'Ceras Hercules', 55, 'active', 'CP0057', NULL),
(58, 'labaplatos xm', 54, 'active', 'CP0058', NULL),
(59, 'tubo bisor', 56, 'active', 'CP0059', NULL),
(60, 'Tanque 1100 rotoplas', 51, 'active', 'CP0060', NULL),
(61, 'tanque 600 litros Rotoplas', 51, 'active', 'CP0061', NULL),
(63, 'tanque 750 litros rotoplas', 51, 'active', 'CP0063', NULL),
(64, 'prueba', 0, 'active', 'CP0064', NULL),
(65, 'SERIAL', 37, 'active', 'CP0065', NULL),
(66, 'galletas', 37, 'active', 'CP0066', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compra`
--

CREATE TABLE `compra` (
  `idCompra` int(11) NOT NULL,
  `idProveedor` int(11) DEFAULT NULL,
  `comTipoComprobante` varchar(250) NOT NULL,
  `comSerieCorrelativo` varchar(250) DEFAULT NULL,
  `comTipoPago` varchar(10) DEFAULT NULL,
  `comUrlComprobante` varchar(500) DEFAULT NULL,
  `comDescuento` decimal(15,2) DEFAULT NULL,
  `comEstadoTipoPago` int(11) DEFAULT NULL,
  `comSubTotal` double(15,2) NOT NULL,
  `comTotal` double(15,2) NOT NULL,
  `comMontoDeuda` decimal(15,2) DEFAULT NULL,
  `comMontoPagado` decimal(15,2) DEFAULT NULL,
  `comIgv` double(15,2) NOT NULL,
  `com_cuotas` int(11) DEFAULT NULL,
  `comEstado` int(11) DEFAULT NULL,
  `comSerieComprobante` varchar(50) DEFAULT NULL,
  `comFecha` date DEFAULT NULL,
  `idPersona` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ESTADO CREDITO : 1 debe, 2: completado o pagado; comEstado: 1  viegente, 0 anuladas';

--
-- Volcado de datos para la tabla `compra`
--

INSERT INTO `compra` (`idCompra`, `idProveedor`, `comTipoComprobante`, `comSerieCorrelativo`, `comTipoPago`, `comUrlComprobante`, `comDescuento`, `comEstadoTipoPago`, `comSubTotal`, `comTotal`, `comMontoDeuda`, `comMontoPagado`, `comIgv`, `com_cuotas`, `comEstado`, `comSerieComprobante`, `comFecha`, `idPersona`) VALUES
(12, 2, 'factura', 'C000012', 'contado', NULL, NULL, 2, 2258.69, 2665.25, '0.00', '2666.00', 406.56, 3, 0, 'F000001', '2021-03-29', NULL),
(13, 2, 'boleta', 'C000013', 'contado', 'http://localhost:8000/storage/app/Comprobantes/3f104f95-c3ee-4126-8a4c-1757acfcf354_1616813540.pdf', NULL, 2, 1942.16, 2291.75, '0.00', '2300.00', 349.59, 4, 1, 'B000001', '2021-03-29', NULL),
(14, 2, 'factura', 'C000014', 'credito', NULL, NULL, 2, 578.39, 682.50, '0.00', '683.00', 104.11, 3, 1, 'F000013', '2021-03-29', NULL),
(15, 2, 'boleta', 'C000015', 'credito', NULL, NULL, 2, 840.68, 992.00, '0.00', '992.00', 151.32, 4, 0, 'B000014', '2021-03-29', NULL),
(16, 2, 'factura', 'C000016', 'credito', 'http://localhost:8000/storage/app/Comprobantes/Plan Estándar_1617030543.pdf', NULL, 1, 809.32, 955.00, '555.00', '400.00', 145.68, 2, 1, 'F000015', '2021-03-29', NULL),
(17, 2, 'factura', 'C000017', 'credito', NULL, NULL, 2, 372.88, 440.00, '60.00', '500.00', 67.12, 2, 1, 'F000017', '2021-04-04', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante_pago`
--

CREATE TABLE `comprobante_pago` (
  `id_comprobante_pago` int(11) NOT NULL,
  `cp_serie` varchar(250) NOT NULL,
  `cp_correlativo` int(11) NOT NULL,
  `cp_fecha` datetime NOT NULL,
  `cp_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`cp_data`)),
  `cp_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`cp_response`)),
  `id_venta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compra`
--

CREATE TABLE `detalle_compra` (
  `idCompraDetalle` int(11) NOT NULL,
  `dcCantidad` int(11) NOT NULL,
  `dcPrecioUnitario` double(15,2) NOT NULL,
  `dcSubTotal` double(15,2) NOT NULL,
  `idCompra` int(11) NOT NULL,
  `idProduct` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `detalle_compra`
--

INSERT INTO `detalle_compra` (`idCompraDetalle`, `dcCantidad`, `dcPrecioUnitario`, `dcSubTotal`, `idCompra`, `idProduct`) VALUES
(4, 1, 24.00, 59.75, 4, 76),
(5, 1, 24.00, 59.75, 4, 78),
(6, 1, 22.00, 59.75, 4, 77),
(7, 1, 24.00, 20.55, 5, 76),
(8, 1, 24.00, 59.75, 6, 78),
(9, 1, 22.00, 59.75, 6, 79),
(10, 1, 24.00, 59.75, 6, 80),
(11, 1, 22.00, 18.64, 7, 77),
(12, 1, 24.00, 20.55, 9, 78),
(13, 70, 24.00, 2258.69, 12, 80),
(14, 20, 22.00, 2258.69, 12, 77),
(15, 1, 24.00, 2258.69, 12, 82),
(16, 78, 22.00, 2258.69, 12, 83),
(17, 10, 24.00, 578.39, 12, 78),
(18, 10, 22.00, 578.39, 12, 77),
(19, 10, 22.00, 578.39, 12, 79),
(20, 10, 22.00, 809.32, 16, 77),
(21, 20, 24.00, 809.32, 16, 76),
(22, 20, 13.00, 809.32, 16, 131),
(23, 20, 22.00, 372.88, 17, 77);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_corte_caja`
--

CREATE TABLE `detalle_corte_caja` (
  `id_detalle_corte` int(11) NOT NULL,
  `dcc_cantidad` int(11) DEFAULT NULL,
  `dcc_total` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `dcc_valor` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `dcc_type_money` int(11) DEFAULT NULL,
  `id_corte_caja` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `detalle_corte_caja`
--

INSERT INTO `detalle_corte_caja` (`id_detalle_corte`, `dcc_cantidad`, `dcc_total`, `dcc_valor`, `dcc_type_money`, `id_corte_caja`) VALUES
(189, 70, '700.00', 'S/ 10.00', 2, 134),
(190, 90, '1800.00', 'S/ 20.00', 2, 134),
(191, 50, '5.00', 'S/ 0.10', 1, 134),
(192, 80, '16.00', 'S/ 0.20', 1, 134),
(193, 80, '800.00', 'S/ 10.00', 2, 135),
(194, 10, '200.00', 'S/ 20.00', 2, 135),
(195, 50, '5.00', 'S/ 0.10', 1, 135),
(196, 70, '14.00', 'S/ 0.20', 1, 135),
(197, 60, '600.00', 'S/ 10.00', 2, 136),
(198, 60, '1200.00', 'S/ 20.00', 2, 136),
(199, 50, '5.00', 'S/ 0.10', 1, 136),
(200, 60, '12.00', 'S/ 0.20', 1, 136),
(201, 20, '200.00', 'S/ 10.00', 2, 137),
(202, 6, '120.00', 'S/ 20.00', 2, 137),
(203, 10, '1.00', 'S/ 0.10', 1, 137),
(204, 5, '1.00', 'S/ 0.20', 1, 137),
(205, 10, '100.00', 'S/ 10.00', 2, 138),
(206, 6, '0.60', 'S/ 0.10', 1, 138),
(207, 40, '400.00', 'S/ 10.00', 2, 139),
(208, 20, '2.00', 'S/ 0.10', 1, 139),
(209, 8, '80.00', 'S/ 10.00', 2, 140),
(210, 9, '0.90', 'S/ 0.10', 1, 140),
(211, 20, '200.00', 'S/ 10.00', 2, 141),
(212, 30, '3.00', 'S/ 0.10', 1, 141),
(213, 80, '800.00', 'S/ 10.00', 2, 142),
(214, 50, '5.00', 'S/ 0.10', 1, 142),
(215, 20, '200.00', 'S/ 10.00', 2, 143),
(216, 50, '5.00', 'S/ 0.10', 1, 143),
(217, 80, '800.00', 'S/ 10.00', 2, 144),
(218, 800, '80.00', 'S/ 0.10', 1, 144),
(219, 89, '890.00', 'S/ 10.00', 2, 145),
(220, 79, '7.90', 'S/ 0.10', 1, 145),
(221, 89, '890.00', 'S/ 10.00', 2, 146),
(222, 9, '0.90', 'S/ 0.10', 1, 146),
(223, 40, '400.00', 'S/ 10.00', 2, 147),
(224, 20, '2.00', 'S/ 0.10', 1, 147),
(225, 40, '400', 'S/ 10.00', 2, 148),
(226, 20, '2', 'S/ 0.10', 1, 148);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_venta`
--

CREATE TABLE `detalle_venta` (
  `id_detalle_venta` int(11) NOT NULL,
  `dv_cantidad` int(11) NOT NULL,
  `dv_subtotal` double(15,2) NOT NULL,
  `dv_ganancia` double(15,2) NOT NULL,
  `id_venta` int(11) NOT NULL,
  `id_product` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documento`
--

CREATE TABLE `documento` (
  `id_documento` int(11) NOT NULL,
  `doc_name` varchar(250) NOT NULL,
  `doc_tamanho` int(11) NOT NULL,
  `doc_status` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documento_persona`
--

CREATE TABLE `documento_persona` (
  `id_documento_persona` int(11) NOT NULL,
  `dp_dato` varchar(45) NOT NULL,
  `id_documento` int(11) NOT NULL,
  `id_persona` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historial_pagos_credito`
--

CREATE TABLE `historial_pagos_credito` (
  `id` int(11) NOT NULL,
  `montoPagado` decimal(15,2) DEFAULT NULL,
  `montoDeuda` decimal(15,2) DEFAULT NULL,
  `fechaCreacion` datetime DEFAULT NULL,
  `idVendedor` int(11) DEFAULT NULL,
  `idCompra` int(11) DEFAULT NULL,
  `idVenta` int(11) DEFAULT NULL,
  `deudaPorPagar` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `historial_pagos_credito`
--

INSERT INTO `historial_pagos_credito` (`id`, `montoPagado`, `montoDeuda`, `fechaCreacion`, `idVendedor`, `idCompra`, `idVenta`, `deudaPorPagar`) VALUES
(5, '20.00', '30.50', '2021-03-23 00:00:00', 2, 6, NULL, '10.50'),
(6, '20.00', '30.50', '2021-03-23 00:00:00', 2, 6, NULL, '10.50'),
(7, '20.00', '30.50', '2021-03-23 00:00:00', 2, 6, NULL, '10.50'),
(8, '20.00', '30.50', '2021-03-23 00:00:00', 2, 6, NULL, '10.50'),
(9, '5.00', '10.50', '2021-03-23 00:00:00', 2, 6, NULL, '5.50'),
(10, '2.00', '5.50', '2021-03-23 00:00:00', 2, 6, NULL, '3.50'),
(11, '2.00', '5.50', '2021-03-23 00:00:00', 2, 6, NULL, '3.50'),
(12, '2.00', '5.50', '2021-03-23 00:00:00', 2, 6, NULL, '3.50'),
(13, '10.00', '30.00', '2021-03-23 00:00:00', 2, 6, NULL, '20.00'),
(14, '10.00', '20.00', '2021-03-23 00:00:00', 2, 6, NULL, '10.00'),
(15, '10.00', '10.00', '2021-03-23 22:57:31', 2, 6, NULL, '9.00'),
(16, '10.00', '9.00', '2021-03-23 23:01:29', 2, 6, NULL, '0.00'),
(17, '50.00', '50.50', '2021-03-24 04:58:20', 2, 6, NULL, '0.50'),
(18, '50.00', '50.00', '2021-03-24 05:02:13', 2, 6, NULL, '0.00'),
(19, '50.00', '50.00', '2021-03-24 05:03:48', 2, 6, NULL, '0.00'),
(20, '0.50', '0.50', '2021-03-24 05:05:10', 2, 6, NULL, '0.00'),
(21, '300.00', '665.25', '2021-03-27 12:06:58', 2, 12, NULL, '365.25'),
(22, '100.00', '365.25', '2021-03-27 12:08:03', 2, 12, NULL, '265.25'),
(23, '50.00', '265.25', '2021-03-27 12:09:46', 2, 12, NULL, '215.25'),
(24, '100.00', '215.25', '2021-03-27 12:10:57', 2, 12, NULL, '115.25'),
(25, '100.00', '115.25', '2021-03-27 12:14:47', 2, 12, NULL, '15.25'),
(26, '10.00', '15.25', '2021-03-27 12:16:07', 2, 12, NULL, '5.25'),
(27, '6.00', '5.25', '2021-03-27 12:18:03', 2, 12, NULL, '0.00'),
(28, '100.00', '291.75', '2021-03-27 12:19:54', 2, 13, NULL, '191.75'),
(29, '100.00', '191.75', '2021-03-27 12:21:26', 2, 13, NULL, '91.75'),
(30, '100.00', '91.75', '2021-03-27 12:23:30', 2, 13, NULL, '0.00'),
(31, '22.00', '182.50', '2021-03-27 12:25:37', 2, 14, NULL, '160.50'),
(32, '100.00', '160.50', '2021-03-27 12:28:14', 2, 14, NULL, '60.50'),
(33, '11.00', '60.50', '2021-03-27 12:30:58', 2, 14, NULL, '49.50'),
(34, '20.00', '49.50', '2021-03-27 12:33:04', 2, 14, NULL, '29.50'),
(35, '20.00', '29.50', '2021-03-27 12:37:01', 2, 14, NULL, '9.50'),
(36, '2.00', '9.50', '2021-03-27 12:38:29', 2, 14, NULL, '7.50'),
(37, '8.00', '7.50', '2021-03-27 12:39:57', 2, 14, NULL, '0.00'),
(38, '100.00', '392.00', '2021-03-27 12:46:41', 1, 15, NULL, '292.00'),
(39, '292.00', '292.00', '2021-03-29 10:11:38', 1, 15, NULL, '0.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `icon`
--

CREATE TABLE `icon` (
  `id_icon` int(11) NOT NULL,
  `icon_name` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `codeunic` varchar(50) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `icon`
--

INSERT INTO `icon` (`id_icon`, `icon_name`, `codeunic`) VALUES
(51, 'fas fa-tachometer-alt', '&#xf3fd;'),
(52, 'fas fa-user-cog', '&#xf4fe;'),
(53, 'fas fa-box-open', '&#xf49e;'),
(54, 'fas fa-hands-helping', '&#xf4c4;'),
(55, 'fas fa-shopping-basket', '&#xf291;'),
(56, 'fas fa-shopping-cart', '&#xf07a;'),
(57, 'fas fa-money-check-alt', '&#xf53d;'),
(58, 'fas fa-chart-line', '&#xf201;'),
(59, 'fas fa-cog', '&#xf013;'),
(61, 'fas fa-chart-bar', '&#xf080;'),
(62, 'fas fa-clipboard-list', '&#xf46d;'),
(63, 'fas fa-credit-card', '&#xf09d;'),
(64, 'fas fa-folder-open', '&#xf07c;'),
(65, 'fas fa-handshake', '&#xf2b5;'),
(66, 'fas fa-store', '&#xf54e;'),
(67, 'fas fa-store-alt', '&#xf54f;'),
(68, 'fas fa-th-list', '&#xf00b;');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `id_persona` int(11) NOT NULL,
  `per_nombre` varchar(250) DEFAULT NULL,
  `per_apellido` varchar(250) DEFAULT NULL,
  `per_direccion` varchar(250) DEFAULT NULL,
  `per_celular` varchar(250) DEFAULT NULL,
  `per_tipo` varchar(150) NOT NULL,
  `per_razon_social` text DEFAULT NULL,
  `per_status` varchar(20) DEFAULT NULL,
  `per_tipo_documento` varchar(10) DEFAULT NULL,
  `per_numero_documento` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`id_persona`, `per_nombre`, `per_apellido`, `per_direccion`, `per_celular`, `per_tipo`, `per_razon_social`, `per_status`, `per_tipo_documento`, `per_numero_documento`) VALUES
(47, 'deyvis', 'Garcia Cercado', 'Av.Virgen de candelaria ', '928832212', 'usuario', NULL, 'active', 'DNI', '48762828'),
(85, 'anibal', 'asas', 'sdsds', '333333333', 'usuario', NULL, 'active', 'DNI', '76666666'),
(87, NULL, NULL, 'av.puno', '92222222', 'proveedor', 'RR-HERMANOS FLORES', 'active', 'ruc', '12345678901'),
(89, NULL, NULL, 'av.gironpuno', '222222222', 'proveedor', 'hermanos abaya', 'active', 'RUC', '20299999999'),
(90, NULL, NULL, 'hdhwssssss', '733333333', 'proveedor', 'Hermabos Barzola', 'disabled', 'RUC', '33333333333'),
(91, NULL, NULL, 'sssdsdsds', '555555555', 'proveedor', 'asasa', 'active', 'RUC', '22222222222'),
(92, NULL, NULL, 'ssssdsdsds', '333333333', 'proveedor', 'sasas', 'active', 'RUC', '33333333333'),
(93, NULL, NULL, 'ssdsds', '333333333', 'proveedor', 'asa', 'active', 'RUC', '33333333333'),
(94, NULL, NULL, 'saasa', '222222222', 'proveedor', 'sasa', 'active', 'RUC', '33333333333'),
(95, NULL, NULL, 'sddsdsd', '111111111', 'proveedor', 'saaaaaaaaaaaa', 'active', 'RUC', '22222222222'),
(96, NULL, NULL, 'sasasa', '333333333', 'proveedor', 'sasa', 'active', 'RUC', '33333333333'),
(97, NULL, NULL, 'sasasasa', '999999999', 'proveedor', 'sssssssssss', 'active', 'RUC', '33333311111'),
(98, 'asas', 'sasa', 'sasa', '333333333', 'usuario', NULL, 'active', 'DNI', '33333333');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `privilegio`
--

CREATE TABLE `privilegio` (
  `id_privilegio` int(11) NOT NULL,
  `pri_nombre` varchar(250) NOT NULL,
  `pri_acces` varchar(250) NOT NULL,
  `pri_group` varchar(200) NOT NULL,
  `pri_status` varchar(150) NOT NULL,
  `pri_icon` varchar(200) NOT NULL,
  `id_Padre` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `privilegio`
--

INSERT INTO `privilegio` (`id_privilegio`, `pri_nombre`, `pri_acces`, `pri_group`, `pri_status`, `pri_icon`, `id_Padre`) VALUES
(1, 'Administracion', '', 'Administracion', 'active', 'fas fa-user-cog', 0),
(2, 'Almacen', '', 'Almacen', 'active', 'fas fa-box-open', 0),
(4, 'Inventario', '/inventario', 'Inventario', 'active', 'fas fa-folder-open', 0),
(5, 'Caja', '', 'Caja', 'active', 'fas fa-money-check-alt', 0),
(6, 'Compras', '', 'Compras', 'active', 'fas fa-shopping-basket', 0),
(7, 'Ventas', '', 'Ventas', 'active', 'fas fa-shopping-cart', 0),
(8, 'Sangria', '/sangria', 'Sangria', 'active', 'fas fa-money-check-alt', 0),
(9, 'Reportes', '', 'Reportes', 'active', 'fas fa-chart-bar', 0),
(10, 'Usuarios', '/Administracion/usuarios', 'Administracion', 'active', 'fas fa-money-check-alt', 1),
(11, 'Privilegios', '/Administracion/privilegios', 'Administracion', 'active', 'fas fa-money-check-alt', 1),
(12, 'Permisos', '/Administracion/permisos', 'Administracion', 'active', 'fas fa-money-check-alt', 1),
(13, 'Perfil', '/Administracion/perfil', 'Administracion', 'active', 'fas fa-money-check-alt', 1),
(14, 'Productos', '/Almacen/productos', 'Almacen', 'active', 'fas fa-money-check-alt', 2),
(15, 'Categorias', '/Almacen/categoria', 'Almacen', 'active', 'fas fa-money-check-alt', 2),
(17, 'Unidad Medida', '/Almacen/unidad-medida', 'Almacen', 'active', 'fas fa-money-check-alt', 2),
(18, 'Actualizar Stock', '/Almacen/ajustar-stock', 'Almacen', 'active', 'fas fa-money-check-alt', 2),
(20, 'Crear Compra', '/Compras/index', 'Compras', 'active', '', 6),
(21, 'Historial', '/Compras/historial', 'Compras', 'active', '', 6),
(22, 'crear venta', '/Ventas/index', 'Ventas', 'active', '', 7),
(23, 'Compras', '/Reportes/compras', 'Reportes', 'active', '', 9),
(24, 'Administrar Caja', '/Caja/administracion', 'Caja', 'active', '', 5),
(25, 'Historial Caja', '/Caja/historial', 'Caja', 'active', '', 5),
(26, 'Cuentas por Cobrar', '/Reportes/cuentas-cobrar', 'Reportes', 'active', '', 9),
(27, 'Cuentas por Pagar', '/Reportes/cuentas-pagar', 'Reportes', 'active', '', 9),
(28, 'Reporte Compras', '/Reportes/compras', 'Reportes', 'active', '', 9),
(29, 'Salvatore', '/Administracion/salvatore', 'Administracion', 'active', '', 1),
(30, 'Proveedores', '/Administracion/proveedores', 'Administracion', 'active', '', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product`
--

CREATE TABLE `product` (
  `id_product` int(11) NOT NULL,
  `pro_name` varchar(250) DEFAULT NULL,
  `pro_status` varchar(150) DEFAULT NULL,
  `pro_description` varchar(250) DEFAULT NULL,
  `id_clase_producto` int(11) DEFAULT NULL,
  `id_unidad_medida` int(11) DEFAULT NULL,
  `pro_cod_barra` varchar(100) DEFAULT NULL,
  `pro_code` varchar(10) DEFAULT NULL,
  `id_subclase` int(11) DEFAULT NULL,
  `pro_file` varchar(500) DEFAULT NULL,
  `pro_fecha_creacion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_por_lotes`
--

CREATE TABLE `product_por_lotes` (
  `id_lote` int(11) NOT NULL,
  `lot_name` varchar(50) NOT NULL,
  `lot_status` varchar(10) DEFAULT NULL,
  `lot_code` varchar(20) NOT NULL,
  `lot_expiration_date` date DEFAULT NULL,
  `lot_creation_date` timestamp NULL DEFAULT NULL,
  `id_product` int(11) DEFAULT NULL,
  `lot_cantidad` int(11) DEFAULT NULL,
  `lot_precio_compra` double(15,2) DEFAULT NULL,
  `lot_precio_venta` double(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product_por_lotes`
--

INSERT INTO `product_por_lotes` (`id_lote`, `lot_name`, `lot_status`, `lot_code`, `lot_expiration_date`, `lot_creation_date`, `id_product`, `lot_cantidad`, `lot_precio_compra`, `lot_precio_venta`) VALUES
(41, 'Lote01', NULL, 'LGAS01', '2021-07-14', '2021-07-14 00:00:00', 261, 10, 10.00, 20.00),
(42, 'Lote01', NULL, 'LHEL01', '2021-07-20', '2021-07-20 00:00:00', 261, 20, 10.00, 20.00),
(43, 'Lote01', NULL, 'LAAA01', '2021-07-20', '2021-06-20 00:00:00', 262, 3, 10.00, 20.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_por_unidades`
--

CREATE TABLE `product_por_unidades` (
  `id_product_unidades` int(11) NOT NULL,
  `id_product` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `precio_venta` decimal(15,2) DEFAULT NULL,
  `precio_compra` decimal(15,2) DEFAULT NULL,
  `fecha_vencimiento` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `product_por_unidades`
--

INSERT INTO `product_por_unidades` (`id_product_unidades`, `id_product`, `cantidad`, `precio_venta`, `precio_compra`, `fecha_vencimiento`) VALUES
(1, 260, 80, '30.00', '20.00', '2021-06-30 00:00:00'),
(2, 263, 1, '30.00', '20.00', '2021-06-28 07:46:33'),
(3, 264, 1, '0.00', '0.00', NULL),
(4, 265, 1, '0.00', '0.00', NULL),
(5, 266, 1, '0.00', '0.00', NULL),
(6, 267, 1, '0.00', '0.00', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `registro_sanitario`
--

CREATE TABLE `registro_sanitario` (
  `id_registro_sanitario` int(11) NOT NULL,
  `rs_codigo` varchar(250) NOT NULL,
  `rs_fecha_vencimiento` datetime NOT NULL,
  `rs_description` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `rol_name` varchar(250) NOT NULL,
  `rol_status` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `rol_name`, `rol_status`) VALUES
(1, 'Administrador', 'active'),
(2, 'vendedor', 'active'),
(3, 'usuario', 'active');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_has_privilegio`
--

CREATE TABLE `rol_has_privilegio` (
  `idrol_has_privilegio` int(11) NOT NULL,
  `id_privilegio` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `rol_has_privilegio`
--

INSERT INTO `rol_has_privilegio` (`idrol_has_privilegio`, `id_privilegio`, `id_rol`) VALUES
(1, 10, 1),
(2, 11, 1),
(3, 12, 1),
(4, 13, 1),
(5, 14, 1),
(6, 15, 1),
(8, 17, 1),
(9, 18, 1),
(10, 20, 1),
(11, 21, 1),
(12, 22, 1),
(13, 24, 1),
(14, 25, 1),
(15, 26, 1),
(16, 27, 1),
(17, 28, 1),
(24, 13, 2),
(25, 14, 2),
(26, 15, 2),
(27, 16, 2),
(28, 17, 2),
(30, 30, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sangria`
--

CREATE TABLE `sangria` (
  `id_sangria` int(11) NOT NULL,
  `san_monto` double(15,2) NOT NULL,
  `san_fecha` date NOT NULL,
  `san_tipo_sangria` varchar(150) NOT NULL,
  `san_motivo` text NOT NULL,
  `id_caja` int(11) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `id_unidad_medida` int(11) NOT NULL,
  `um_name` varchar(50) NOT NULL,
  `um_nombre_corto` varchar(10) NOT NULL,
  `um_status` varchar(20) NOT NULL,
  `um_fecha_creacion` timestamp NULL DEFAULT NULL,
  `um_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `unidad_medida`
--

INSERT INTO `unidad_medida` (`id_unidad_medida`, `um_name`, `um_nombre_corto`, `um_status`, `um_fecha_creacion`, `um_code`) VALUES
(9, 'kilo', 'kl', 'active', '2021-02-15 22:45:22', 'C0001'),
(10, 'Gramo', 'gr', 'active', '2021-02-15 23:00:53', 'C0002'),
(15, 'Unidad', 'un', 'active', '2021-05-16 13:28:02', 'C0003'),
(16, 'Tonelaas', 'tn', 'active', '2021-05-16 13:28:04', 'C0004'),
(17, 'Litro', 'lt', 'active', '2021-05-16 13:28:38', 'C0005'),
(18, 'Metro', 'mt', 'active', '2021-05-16 13:29:29', 'C0006'),
(19, 'Centimetro', 'cm', 'active', '2021-05-16 13:30:05', 'C0007'),
(20, 'kilo1', 'kl', 'active', '2021-02-15 22:45:22', 'C0001'),
(21, 'Gramo1', 'gr', 'active', '2021-02-15 23:00:53', 'C0002'),
(22, 'Unidad1', 'un', 'active', '2021-05-16 13:28:02', 'C0003'),
(23, 'Tonelaas1', 'tn', 'active', '2021-05-16 13:28:04', 'C0004'),
(24, 'Litro1', 'lt', 'active', '2021-05-16 13:28:38', 'C0005'),
(25, 'Metro1', 'mt', 'active', '2021-05-16 13:29:29', 'C0006'),
(26, 'Centimetro1', 'cm', 'active', '2021-05-16 13:30:05', 'C0007'),
(27, 'kilo2', 'kl', 'active', '2021-02-15 22:45:22', 'C0001'),
(28, 'Gramo2', 'gr', 'active', '2021-02-15 23:00:53', 'C0002'),
(29, 'Unidad2', 'un', 'active', '2021-05-16 13:28:02', 'C0003'),
(30, 'Tonelaas2', 'tn', 'active', '2021-05-16 13:28:04', 'C0004'),
(31, 'Litro2', 'lt', 'active', '2021-05-16 13:28:38', 'C0005'),
(32, 'Metro2', 'mt', 'active', '2021-05-16 13:29:29', 'C0006'),
(33, 'Centimetro2', 'cm', 'active', '2021-05-16 13:30:05', 'C0007'),
(34, 'kilo2', 'kl', 'active', '2021-02-15 22:45:22', 'C0001'),
(35, 'Gramo2', 'gr', 'active', '2021-02-15 23:00:53', 'C0002'),
(36, 'Unidad2', 'un', 'active', '2021-05-16 13:28:02', 'C0003'),
(37, 'Tonelaas2', 'tn', 'active', '2021-05-16 13:28:04', 'C0004'),
(38, 'Litro3', 'lt', 'active', '2021-05-16 13:28:38', 'C0005'),
(39, 'Metro3', 'mt', 'active', '2021-05-16 13:29:29', 'C0006'),
(40, 'Centimetro3', 'cm', 'active', '2021-05-16 13:30:05', 'C0007');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `us_usuario` varchar(250) NOT NULL,
  `us_password` varchar(250) NOT NULL,
  `us_status` varchar(150) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `us_token` varchar(250) NOT NULL,
  `id_persona` int(11) NOT NULL,
  `us_passwor_view` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`id_user`, `us_usuario`, `us_password`, `us_status`, `id_rol`, `us_token`, `id_persona`, `us_passwor_view`) VALUES
(13, 'deyvisgc', '$2y$10$y76W0r.tIqm8QAk2iNBztOP/onXWATOrxMHJxw2ocHdpoXIwe2xfK', 'active', 1, 'M0FHZEdzRXFGUmhVRTZTbGFIOVpKMXRiWjBGc0tCeUlwUTVhdXBWTA==', 47, '{\"ciphertext\":\"StAkbKyB+vZ6Lkl33PJ20A==\",\"iv\":\"fd7fc47ce9503885e9e7a694fe96c049\",\"salt\":\"34f176290648fe72be3b2ab8c6e11eec4104fc3b042c83fc0ea91c761e8b29d5b78b30165d28a4ec9f9d2a95c23452c1a536509d08f92441456f536dd1a3f28d9279b3de60bbe7201e2f08eb9c00554bfe0d00d5b1163e58a6e0183b03dc3ea2d427d09991eab57b76ffcfac06975b7effe7835b632dbf4c66068b32c8152a038f386746584369fefa0eb0c6539960b8b1522e40c022b209d9459e6f1a1f3b4053a00f0ee7a66a2b8d0f235aad8a2df5261f5a57cdfeec2bab83f5c80e4f11f975526edcc2e283818ec69f18cbde27c0de236dbb5e0a63d3fb9eca256c5dd573447823c97dde9e6cd7d6f076b6d352f7adc4a3e647df11b7d5a41a78a968987e\"}'),
(52, 'anibalgc1', '$2y$10$ZmD2ylyJmFTWLrYNw0PSIO9StnX3Eg3NmnTSJ0k5LJRMsZJvbyg5m', 'active', 2, 'UFg2UTg0b01DWDQ1RmxHMmFoaTJ3YWgxMXNVRlNGdXZFa3VjUGVHbUphM2tHQkhSUWw=', 85, '{\"ciphertext\":\"9Z08x1CzaOV7pvO\\/6f0sjQ==\",\"iv\":\"1385d0789d3591315c5c0015b1e6fe13\",\"salt\":\"18330eb9ad7871c29c8fb11a4eb16fa1a4a0c37859ac6fab16b41b2c070b715735d712583fcab3691a755a9ea6552fe1a0ff5401baed5f1fb9802d5669e4936882e11e9655ac3634a4e33b89d39a4d20db607b17e86578222073ffbddfb3f9a01ee466a3329768826ffbbdb3420093a1c36227388e19734c8b799ddfb53a0033c5fe0b4cbd0814f814e2633e3bf0c2464b1c7dc12913c83dd798fd892018862077c351a55197dfce24c46137ff158a7e50605cfe58676794bd1b25f8faffbf29ee0c20cbfd64e15ef3788232c232f99081e1260cd1497803f0f29ea7af5f28ccf3404c5fd7db6812120d9ced2945d45b0a9b65d7a0f7df75d056a97081bf106c\"}'),
(53, 'deyvis', '$2y$10$vQxCmDXeXZz21wuSUDuoIuMLULC/GWcHV2UzbyerIlnilpU/tNvWq', 'active', 2, 'd0RWMkhvVW1XamNzNEFreXBPZXhzTlV6U2EydTRyYjZ2c2JMZ2VOV3pTc3ZiQlF0UnA=', 98, '{\"ciphertext\":\"5ttR5\\/64PRzhrnKq1wMSJw==\",\"iv\":\"116dd92e784b296e11b87805ef4fe5f1\",\"salt\":\"3cb3bd7e3d1208ba399a9f74d8c2faf726f5301224023caba34d8aac2634218da22904afc37d64fcc9421a51f2f1864637298cca0d5de3d460ef8df4687ddbb5f5b7ac8712ff97bc4b5ea28990c71c4229d8d8ac70f2683a34b7abbfd7d17da6126526e57737d25aab8dac875862e17b1498b67a62ff5b62ce4aa0f75fbf51b34e6e62aa770ddf1596d571ddc8eb9131c6b211599b7b431a581a8211d0a079067d455aab1185d45b05b656a7ee365c0e129a07ab73299f5175b81fb127f263fb42a7b33335d81cbaff6be8cc7648da68f6e7a17616be1132084dad06fa8f88413a29433be30636cc20d74cee8d10e2f8e26022d51af2a26308dd027178aad70f\"}');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id_venta` int(11) NOT NULL,
  `ven_fecha` datetime NOT NULL,
  `ven_sub_total` double(15,2) NOT NULL,
  `ven_total` double(15,2) NOT NULL,
  `ven_descuento` double(15,2) NOT NULL,
  `ven_igv` double(15,2) NOT NULL,
  `ven_codigo` varchar(250) NOT NULL,
  `ven_tipo_venta` varchar(250) NOT NULL,
  `ven_tipo_pago` varchar(250) NOT NULL,
  `id_persona` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  ADD PRIMARY KEY (`id_arqueo_caja`);

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`id_caja`),
  ADD KEY `fk_caja_user1_idx` (`id_user`);

--
-- Indices de la tabla `caja_corte`
--
ALTER TABLE `caja_corte`
  ADD PRIMARY KEY (`id_caja_corte`);

--
-- Indices de la tabla `caja_corte_diario`
--
ALTER TABLE `caja_corte_diario`
  ADD PRIMARY KEY (`id_caja_corte_diario`);

--
-- Indices de la tabla `caja_corte_semanal`
--
ALTER TABLE `caja_corte_semanal`
  ADD PRIMARY KEY (`id_corte_semanal`);

--
-- Indices de la tabla `caja_historial`
--
ALTER TABLE `caja_historial`
  ADD PRIMARY KEY (`id_caja_historial`),
  ADD KEY `fk_caja_historial_user1_idx` (`id_user`),
  ADD KEY `fk_caja_historial_caja1_idx` (`id_caja`);

--
-- Indices de la tabla `carrito`
--
ALTER TABLE `carrito`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `carrito_id_uindex` (`id`);

--
-- Indices de la tabla `clase_producto`
--
ALTER TABLE `clase_producto`
  ADD PRIMARY KEY (`id_clase_producto`);

--
-- Indices de la tabla `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`idCompra`);

--
-- Indices de la tabla `comprobante_pago`
--
ALTER TABLE `comprobante_pago`
  ADD PRIMARY KEY (`id_comprobante_pago`),
  ADD KEY `fk_comprobante_pago_venta1_idx` (`id_venta`);

--
-- Indices de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD PRIMARY KEY (`idCompraDetalle`);

--
-- Indices de la tabla `detalle_corte_caja`
--
ALTER TABLE `detalle_corte_caja`
  ADD PRIMARY KEY (`id_detalle_corte`),
  ADD UNIQUE KEY `detalle_corte_caja_id_corte_caja_uindex` (`id_detalle_corte`);

--
-- Indices de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD PRIMARY KEY (`id_detalle_venta`),
  ADD KEY `fk_detalle_venta_venta1_idx` (`id_venta`),
  ADD KEY `fk_detalle_venta_product1_idx` (`id_product`);

--
-- Indices de la tabla `documento`
--
ALTER TABLE `documento`
  ADD PRIMARY KEY (`id_documento`);

--
-- Indices de la tabla `documento_persona`
--
ALTER TABLE `documento_persona`
  ADD PRIMARY KEY (`id_documento_persona`),
  ADD KEY `fk_documento_persona_documento1_idx` (`id_documento`),
  ADD KEY `fk_documento_persona_persona1_idx` (`id_persona`);

--
-- Indices de la tabla `historial_pagos_credito`
--
ALTER TABLE `historial_pagos_credito`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `icon`
--
ALTER TABLE `icon`
  ADD PRIMARY KEY (`id_icon`),
  ADD UNIQUE KEY `icon_id_icon_uindex` (`id_icon`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`id_persona`);

--
-- Indices de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  ADD PRIMARY KEY (`id_privilegio`);

--
-- Indices de la tabla `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id_product`),
  ADD KEY `fk_product_clase_producto1_idx` (`id_clase_producto`),
  ADD KEY `fk_product_unidad_medida1_idx` (`id_unidad_medida`);

--
-- Indices de la tabla `product_por_lotes`
--
ALTER TABLE `product_por_lotes`
  ADD PRIMARY KEY (`id_lote`);

--
-- Indices de la tabla `product_por_unidades`
--
ALTER TABLE `product_por_unidades`
  ADD PRIMARY KEY (`id_product_unidades`);

--
-- Indices de la tabla `registro_sanitario`
--
ALTER TABLE `registro_sanitario`
  ADD PRIMARY KEY (`id_registro_sanitario`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indices de la tabla `rol_has_privilegio`
--
ALTER TABLE `rol_has_privilegio`
  ADD PRIMARY KEY (`idrol_has_privilegio`),
  ADD KEY `fk_rol_has_privilegio_privilegio_idx` (`id_privilegio`),
  ADD KEY `fk_rol_has_privilegio_rol1_idx` (`id_rol`);

--
-- Indices de la tabla `sangria`
--
ALTER TABLE `sangria`
  ADD PRIMARY KEY (`id_sangria`),
  ADD KEY `fk_sangria_caja1_idx` (`id_caja`),
  ADD KEY `fk_sangria_user1_idx` (`id_user`);

--
-- Indices de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  ADD PRIMARY KEY (`id_unidad_medida`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `users_us_usuario_uindex` (`us_usuario`),
  ADD KEY `fk_user_rol1_idx` (`id_rol`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id_venta`),
  ADD KEY `fk_venta_persona1_idx` (`id_persona`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  MODIFY `id_arqueo_caja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `id_caja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `caja_corte`
--
ALTER TABLE `caja_corte`
  MODIFY `id_caja_corte` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;

--
-- AUTO_INCREMENT de la tabla `caja_corte_diario`
--
ALTER TABLE `caja_corte_diario`
  MODIFY `id_caja_corte_diario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=73;

--
-- AUTO_INCREMENT de la tabla `caja_corte_semanal`
--
ALTER TABLE `caja_corte_semanal`
  MODIFY `id_corte_semanal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `caja_historial`
--
ALTER TABLE `caja_historial`
  MODIFY `id_caja_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT de la tabla `carrito`
--
ALTER TABLE `carrito`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=202;

--
-- AUTO_INCREMENT de la tabla `clase_producto`
--
ALTER TABLE `clase_producto`
  MODIFY `id_clase_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `idCompra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `idCompraDetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `detalle_corte_caja`
--
ALTER TABLE `detalle_corte_caja`
  MODIFY `id_detalle_corte` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=227;

--
-- AUTO_INCREMENT de la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  MODIFY `id_detalle_venta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `documento`
--
ALTER TABLE `documento`
  MODIFY `id_documento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `documento_persona`
--
ALTER TABLE `documento_persona`
  MODIFY `id_documento_persona` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `historial_pagos_credito`
--
ALTER TABLE `historial_pagos_credito`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `icon`
--
ALTER TABLE `icon`
  MODIFY `id_icon` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  MODIFY `id_privilegio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=268;

--
-- AUTO_INCREMENT de la tabla `product_por_lotes`
--
ALTER TABLE `product_por_lotes`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT de la tabla `product_por_unidades`
--
ALTER TABLE `product_por_unidades`
  MODIFY `id_product_unidades` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `registro_sanitario`
--
ALTER TABLE `registro_sanitario`
  MODIFY `id_registro_sanitario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `rol_has_privilegio`
--
ALTER TABLE `rol_has_privilegio`
  MODIFY `idrol_has_privilegio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `sangria`
--
ALTER TABLE `sangria`
  MODIFY `id_sangria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `id_unidad_medida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id_venta` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `caja`
--
ALTER TABLE `caja`
  ADD CONSTRAINT `fk_caja_user1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `caja_historial`
--
ALTER TABLE `caja_historial`
  ADD CONSTRAINT `fk_caja_historial_caja1` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_caja_historial_user1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comprobante_pago`
--
ALTER TABLE `comprobante_pago`
  ADD CONSTRAINT `fk_comprobante_pago_venta1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `detalle_venta`
--
ALTER TABLE `detalle_venta`
  ADD CONSTRAINT `fk_detalle_venta_product1` FOREIGN KEY (`id_product`) REFERENCES `product` (`id_product`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_detalle_venta_venta1` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `documento_persona`
--
ALTER TABLE `documento_persona`
  ADD CONSTRAINT `fk_documento_persona_documento1` FOREIGN KEY (`id_documento`) REFERENCES `documento` (`id_documento`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_documento_persona_persona1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `fk_product_clase_producto1` FOREIGN KEY (`id_clase_producto`) REFERENCES `clase_producto` (`id_clase_producto`),
  ADD CONSTRAINT `fk_product_unidad_medida1` FOREIGN KEY (`id_unidad_medida`) REFERENCES `unidad_medida` (`id_unidad_medida`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `sangria`
--
ALTER TABLE `sangria`
  ADD CONSTRAINT `fk_sangria_caja1` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sangria_user1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_rol1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_venta_persona1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
