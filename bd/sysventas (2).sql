-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 01-10-2021 a las 04:08:42
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
-- Base de datos: `sysventas`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `addCarrCompra` (IN `in_cantidad` INT, IN `in_precio_compra` DECIMAL(15,2), IN `in_idProducto` INT, IN `in_idProveedor` INT, IN `in_idCaja` INT, IN `in_pro_nombre` VARCHAR(200), IN `in_cantidad_minima` INT, IN `in_codeBarra` VARCHAR(50))  begin
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `addCompra` (IN `in_subtotal` DECIMAL(15,2), IN `in_total` DECIMAL(15,2), IN `in_igv` DECIMAL(15,2), IN `in_tipoComprobante` VARCHAR(20), IN `in_tipoPago` VARCHAR(20), IN `in_idProveedor` INT, IN `in_cuotas` INT, IN `in_montoPagado` DECIMAL(15,2), IN `in_montoDeudaOrVuelto` DECIMAL(15,2))  begin
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
-- Estructura de tabla para la tabla `almacen`
--

CREATE TABLE `almacen` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(100) CHARACTER SET utf8 NOT NULL,
  `direccion` varchar(500) CHARACTER SET utf8 DEFAULT NULL,
  `tienda` int(11) DEFAULT NULL,
  `codigo` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `estado` varchar(50) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `almacen`
--

INSERT INTO `almacen` (`id`, `descripcion`, `direccion`, `tienda`, `codigo`, `estado`) VALUES
(2, 'Almacen General', 'Av-lima-peru', NULL, 'AL0001', 'active'),
(3, 'Almacen 2', 'av-per', NULL, 'Al0002', 'active');

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
-- Estructura de tabla para la tabla `auditoria_universal`
--

CREATE TABLE `auditoria_universal` (
  `id` int(11) NOT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `accion` text DEFAULT NULL,
  `id_persona` int(11) DEFAULT NULL,
  `usuarioCreador` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `modulo` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_categorias` int(11) DEFAULT NULL,
  `id_actualizar_stock` int(11) DEFAULT NULL,
  `id_caja` int(11) DEFAULT NULL,
  `id_compra` int(11) DEFAULT NULL,
  `id_venta` int(11) DEFAULT NULL,
  `id_tipo_cliente_proveedor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

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
(9, 'CAJAOO1', 'DSDSSD', 'active', 59, '2021-04-30 19:38:07');

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
(68, 'tanques', 0, 'active', 'CP0068', '2021-09-01'),
(72, 'Lavaderos De Baño', 0, 'active', 'CP0072', '2021-09-01'),
(73, 'Lavadero De Cocina', 0, 'active', 'CP0073', '2021-09-01'),
(80, 'Lavaderos xm', 73, 'active', 'CP0080', '2021-09-02'),
(82, 'Mescladora Para Baño', 81, 'active', 'CP0082', '2021-09-03'),
(83, 'Mescladoras De Baño', 0, 'disable', 'CP0083', '2021-09-03');

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
-- Estructura de tabla para la tabla `historial_traslado`
--

CREATE TABLE `historial_traslado` (
  `id` int(11) NOT NULL,
  `producto` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `id_traslado` int(11) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `historial_traslado`
--

INSERT INTO `historial_traslado` (`id`, `producto`, `id_traslado`, `stock`) VALUES
(1, 'INKA KOLa', 2, 10),
(2, 'INKA KOLa', 3, 10);

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
-- Estructura de tabla para la tabla `impuestos`
--

CREATE TABLE `impuestos` (
  `id` int(11) NOT NULL,
  `tipo_impuesto` varchar(50) CHARACTER SET utf8 NOT NULL,
  `codigoImpuesto` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `estado` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `monto_impuesto` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inventario`
--

CREATE TABLE `inventario` (
  `id` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `producto` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `stock` int(11) DEFAULT NULL,
  `id_almacen` int(11) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `inventario`
--

INSERT INTO `inventario` (`id`, `id_producto`, `producto`, `stock`, `id_almacen`, `fecha_creacion`) VALUES
(20, 408, 'INKA KOLa', 90, 2, '2021-09-29 23:19:00'),
(24, NULL, 'INKA KOLa', 10, 3, '2021-09-30 08:51:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `id_persona` int(11) NOT NULL,
  `per_tipo_documento` varchar(10) DEFAULT NULL,
  `per_numero_documento` varchar(30) DEFAULT NULL,
  `per_nombre` varchar(250) DEFAULT NULL,
  `per_razon_social` text DEFAULT NULL,
  `per_fecha_creacion` date DEFAULT NULL,
  `per_codigo_interno` varchar(50) NOT NULL,
  `id_tipo_cliente_proveedor` int(11) DEFAULT NULL,
  `id_departamento` varchar(10) DEFAULT NULL,
  `id_provincia` varchar(10) DEFAULT NULL,
  `id_distrito` varchar(10) DEFAULT NULL,
  `per_direccion` varchar(250) DEFAULT NULL,
  `per_celular` varchar(250) DEFAULT NULL,
  `per_email` varchar(50) DEFAULT NULL,
  `per_status` varchar(20) DEFAULT NULL,
  `per_tipo` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`id_persona`, `per_tipo_documento`, `per_numero_documento`, `per_nombre`, `per_razon_social`, `per_fecha_creacion`, `per_codigo_interno`, `id_tipo_cliente_proveedor`, `id_departamento`, `id_provincia`, `id_distrito`, `per_direccion`, `per_celular`, `per_email`, `per_status`, `per_tipo`) VALUES
(164, 'dni', '48762823', 'DEIVIS RONALD GARCIA CERCADO', '', '2021-09-19', '3333', 1, '', '', '', '', '', '', 'active', 'usuario'),
(196, 'ruc', '10164767421', 'Doig Fernandez Julio Carlos', 'Doig Fernandez Julio Carlos', '2021-09-24', '', NULL, '', '', '', '', '', '', 'active', 'cliente'),
(198, 'ruc', '10164767421', 'Doig Fernandez Julio Carlos', 'Doig Fernandez Julio Carlos', '2021-09-24', '', NULL, '', '', '', '', '', '', 'active', ''),
(199, 'ruc', '10164767421', 'Doig Fernandez Julio Carlos', 'Doig Fernandez Julio Carlos', '2021-09-24', '', 1, '', '', '', '', '', '', 'active', 'proveedor'),
(200, 'ruc', '10164090588', 'Samillan Alache Maria Melania', 'Samillan Alache Maria Melania', '2021-09-24', '', NULL, '', '', '', '', '', '', 'active', 'cliente'),
(201, 'ruc', '10164090588', 'Samillan Alache Maria Melania', 'Samillan Alache Maria Melania', '2021-09-24', '', 11, '', '', '', '', '', '', 'active', 'proveedor'),
(202, 'ruc', '10164120517', 'Quiroz De Balcazar Judith Lady', 'Quiroz De Balcazar Judith Lady', '2021-09-24', '8888', 2, '', '', '', '', '', '', 'active', 'proveedor');

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
(20, 'Nuevo', '/Compras/index', 'Compras', 'active', '', 6),
(21, 'Listado', '/Compras/historial', 'Compras', 'active', '', 6),
(22, 'crear venta', '/Ventas/index', 'Ventas', 'active', '', 7),
(23, 'Compras', '/Reportes/compras', 'Reportes', 'active', '', 9),
(24, 'Administrar Caja', '/Caja/administracion', 'Caja', 'active', '', 5),
(25, 'Historial Caja', '/Caja/historial', 'Caja', 'active', '', 5),
(29, 'Salvatore', '/Administracion/salvatore', 'Administracion', 'active', '', 1),
(32, 'Clientes', '/clientes', 'Clientes', 'active', 'fas fa-user-plus', 0),
(35, 'Cliente', '/Clientes/nuevo-cliente', 'Clientes', 'active', '', 32),
(36, 'Tipo Cliente', '/Clientes/tipo-cliente', 'Clientes', 'active', '', 32),
(37, 'Proveedor', '/Compras/proveedor', 'Compras', 'active', '', 6),
(38, 'Finanzas', '/finanzas', 'Finanzas', 'active', 'fas fa-credit-card', 0),
(39, 'Cuentas por pagar', '/Finanzas/cuentas-por-pagar', 'Finanzas', 'active', 'fas fa-credit-card', 38),
(40, 'Cuentas por cobrar', '/Finanzas/cuentas-por-cobrar', 'Finanzas', 'active', 'fas fa-credit-card', 38),
(41, 'Sangria', '/Finanzas/sangria', 'Finanzas', 'active', 'fas fa-credit-card', 38),
(42, 'Ganancias', '/Finanzas/ganancias', 'Finanzas', 'active', 'fas fa-credit-card', 38),
(48, 'Movimientos', '/Inventario/movimientos', 'Inventario', 'active', '', 4),
(49, 'Traslados', '/Inventario/traslados', 'Inventario', 'active', '', 4),
(50, 'Devoluciones', '/Inventario/devoluciones', 'Inventario', 'active', 'fas fa-credit-card', 4),
(51, 'Reporte Inventario', '/Inventario/reporte-inventario', 'Inventario', 'active', '', 4),
(52, 'Reposición de Productos', '/Inventario/reposicion-productos', 'Inventario', 'active', '', 4);

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
  `pro_fecha_creacion` date DEFAULT NULL,
  `id_almacen` int(11) DEFAULT NULL,
  `pro_fecha_vencimiento` date DEFAULT NULL,
  `id_lote` int(11) DEFAULT NULL,
  `pro_marca` varchar(100) DEFAULT NULL,
  `pro_modelo` varchar(100) DEFAULT NULL,
  `pro_moneda` varchar(50) DEFAULT NULL,
  `pro_stock_inicial` int(11) DEFAULT NULL,
  `pro_stock_minimo` int(11) DEFAULT NULL,
  `incluye_igv` tinyint(1) DEFAULT NULL,
  `incluye_bolsa` tinyint(1) DEFAULT NULL,
  `id_afectacion` int(11) DEFAULT NULL,
  `pro_precio_compra` decimal(15,2) DEFAULT NULL,
  `pro_precio_venta` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product`
--

INSERT INTO `product` (`id_product`, `pro_name`, `pro_status`, `pro_description`, `id_clase_producto`, `id_unidad_medida`, `pro_cod_barra`, `pro_code`, `id_subclase`, `pro_file`, `pro_fecha_creacion`, `id_almacen`, `pro_fecha_vencimiento`, `id_lote`, `pro_marca`, `pro_modelo`, `pro_moneda`, `pro_stock_inicial`, `pro_stock_minimo`, `incluye_igv`, `incluye_bolsa`, `id_afectacion`, `pro_precio_compra`, `pro_precio_venta`) VALUES
(408, 'Inka Kola', 'active', 'Hhhh', NULL, 58, '', 'P0408', NULL, NULL, '2021-09-29', 2, '2021-09-29', NULL, '', '', 'soles', 100, 5, 1, 0, 1, '10.00', '20.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_history`
--

CREATE TABLE `product_history` (
  `id` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_lote` int(11) DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `stock_antiguo` int(11) DEFAULT NULL,
  `stock_nuevo` int(11) DEFAULT NULL,
  `stock_total` int(11) DEFAULT NULL,
  `precio_compra` decimal(15,2) DEFAULT NULL,
  `precio_venta` decimal(15,2) DEFAULT NULL,
  `almacen` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_por_lotes`
--

CREATE TABLE `product_por_lotes` (
  `id_lote` int(11) NOT NULL,
  `lot_name` varchar(50) NOT NULL,
  `lot_status` varchar(10) DEFAULT NULL,
  `lot_code` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product_por_lotes`
--

INSERT INTO `product_por_lotes` (`id_lote`, `lot_name`, `lot_status`, `lot_code`) VALUES
(41, 'Lote01', 'active', 'LGAS01'),
(42, 'Lote01', 'active', 'LHEL01'),
(43, 'Lote01', 'active', 'LAAA01');

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
(33, 35, 1),
(34, 36, 1),
(35, 37, 1),
(36, 39, 1),
(37, 40, 1),
(38, 41, 1),
(39, 42, 1),
(45, 48, 1),
(46, 49, 1),
(47, 50, 1),
(48, 51, 1),
(49, 52, 1);

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
-- Estructura de tabla para la tabla `serie_compra`
--

CREATE TABLE `serie_compra` (
  `id` int(11) NOT NULL,
  `tipo_comprobante` int(11) DEFAULT NULL,
  `serie_tipo_comprobante` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `tipo_serie` varchar(20) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `serie_compra`
--

INSERT INTO `serie_compra` (`id`, `tipo_comprobante`, `serie_tipo_comprobante`, `tipo_serie`) VALUES
(1, 0, 'B0', 'compra'),
(2, 1, 'F0', 'compra');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_afectacion`
--

CREATE TABLE `tipo_afectacion` (
  `id` int(11) NOT NULL,
  `tipo_afectacion` varchar(50) CHARACTER SET utf8 NOT NULL,
  `descripcion` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `monto_afectacion` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tipo_afectacion`
--

INSERT INTO `tipo_afectacion` (`id`, `tipo_afectacion`, `descripcion`, `monto_afectacion`) VALUES
(1, 'igv', 'Gravado - Operación Onerosa', '0.18'),
(2, 'igv', 'Exonerado - Operación Onerosa', '0.18'),
(3, 'bolsa', 'Impuesto- Bolsa Plastica', '0.10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_cliente_proveedor`
--

CREATE TABLE `tipo_cliente_proveedor` (
  `id` int(11) NOT NULL,
  `descripcion` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `tipo_estado` varchar(10) DEFAULT NULL,
  `tipo_fecha_creacion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tipo_cliente_proveedor`
--

INSERT INTO `tipo_cliente_proveedor` (`id`, `descripcion`, `tipo_estado`, `tipo_fecha_creacion`) VALUES
(1, 'Interno', 'active', '2021-09-22'),
(2, 'Distribuidor', 'active', '2021-09-22'),
(11, 'Exportaciones', 'disable', '2021-09-22');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `traslado`
--

CREATE TABLE `traslado` (
  `id` int(11) NOT NULL,
  `motivo_traslado` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `cantidad_total_producto` int(11) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `almacen_origen` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `almacen_destino` varchar(100) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Volcado de datos para la tabla `traslado`
--

INSERT INTO `traslado` (`id`, `motivo_traslado`, `cantidad_total_producto`, `fecha_creacion`, `almacen_origen`, `almacen_destino`) VALUES
(1, 'sasasasa', 5, '2021-09-29 23:51:00', 'Almacen General', 'Almacen 2'),
(2, 'asasa', 5, '2021-09-30 00:21:00', 'Almacen General', 'Almacen 2'),
(3, '2kjkjkjkj', 5, '2021-09-30 08:51:00', 'Almacen General', 'Almacen 2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ubigeo`
--

CREATE TABLE `ubigeo` (
  `ubigeo1` char(6) DEFAULT NULL,
  `dpto` varchar(32) DEFAULT NULL,
  `prov` varchar(32) DEFAULT NULL,
  `distrito` varchar(32) DEFAULT NULL,
  `ubigeo2` char(6) DEFAULT NULL,
  `orden` varchar(1) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `ubigeo`
--

INSERT INTO `ubigeo` (`ubigeo1`, `dpto`, `prov`, `distrito`, `ubigeo2`, `orden`) VALUES
('010101', 'Amazonas', 'Chachapoyas', 'Chachapoyas', '010101', '0'),
('010102', 'Amazonas', 'Chachapoyas', 'Asuncion', '010102', '0'),
('010103', 'Amazonas', 'Chachapoyas', 'Balsas', '010103', '0'),
('010104', 'Amazonas', 'Chachapoyas', 'Cheto', '010104', '0'),
('010105', 'Amazonas', 'Chachapoyas', 'Chiliquin', '010105', '0'),
('010106', 'Amazonas', 'Chachapoyas', 'Chuquibamba', '010106', '0'),
('010107', 'Amazonas', 'Chachapoyas', 'Granada', '010107', '0'),
('010108', 'Amazonas', 'Chachapoyas', 'Huancas', '010108', '0'),
('010109', 'Amazonas', 'Chachapoyas', 'La Jalca', '010109', '0'),
('010110', 'Amazonas', 'Chachapoyas', 'Leymebamba', '010110', '0'),
('010111', 'Amazonas', 'Chachapoyas', 'Levanto', '010111', '0'),
('010112', 'Amazonas', 'Chachapoyas', 'Magdalena', '010112', '0'),
('010113', 'Amazonas', 'Chachapoyas', 'Mariscal Castilla', '010113', '0'),
('010114', 'Amazonas', 'Chachapoyas', 'Molinopampa', '010114', '0'),
('010115', 'Amazonas', 'Chachapoyas', 'Montevideo', '010115', '0'),
('010116', 'Amazonas', 'Chachapoyas', 'Olleros', '010116', '0'),
('010117', 'Amazonas', 'Chachapoyas', 'Quinjalca', '010117', '0'),
('010118', 'Amazonas', 'Chachapoyas', 'San Francisco De Daguas', '010118', '0'),
('010119', 'Amazonas', 'Chachapoyas', 'San Isidro De Maino', '010119', '0'),
('010120', 'Amazonas', 'Chachapoyas', 'Soloco', '010120', '0'),
('010121', 'Amazonas', 'Chachapoyas', 'Sonche', '010121', '0'),
('010201', 'Amazonas', 'Bagua', 'La Peca', '010201', '0'),
('010202', 'Amazonas', 'Bagua', 'Aramango', '010202', '0'),
('010203', 'Amazonas', 'Bagua', 'Copallin', '010203', '0'),
('010204', 'Amazonas', 'Bagua', 'El Parco', '010204', '0'),
('010206', 'Amazonas', 'Bagua', 'Imaza', '010205', '0'),
('010301', 'Amazonas', 'Bongara', 'Jumbilla', '010301', '0'),
('010302', 'Amazonas', 'Bongara', 'Corosha', '010304', '0'),
('010303', 'Amazonas', 'Bongara', 'Cuispes', '010305', '0'),
('010304', 'Amazonas', 'Bongara', 'Chisquilla', '010302', '0'),
('010305', 'Amazonas', 'Bongara', 'Churuja', '010303', '0'),
('010306', 'Amazonas', 'Bongara', 'Florida', '010306', '0'),
('010307', 'Amazonas', 'Bongara', 'Recta', '010308', '0'),
('010308', 'Amazonas', 'Bongara', 'San Carlos', '010309', '0'),
('010309', 'Amazonas', 'Bongara', 'Shipasbamba', '010310', '0'),
('010310', 'Amazonas', 'Bongara', 'Valera', '010311', '0'),
('010311', 'Amazonas', 'Bongara', 'Yambrasbamba', '010312', '0'),
('010312', 'Amazonas', 'Bongara', 'Jazan', '010307', '0'),
('010401', 'Amazonas', 'Luya', 'Lamud', '010501', '0'),
('010402', 'Amazonas', 'Luya', 'Camporredondo', '010502', '0'),
('010403', 'Amazonas', 'Luya', 'Cocabamba', '010503', '0'),
('010404', 'Amazonas', 'Luya', 'Colcamar', '010504', '0'),
('010405', 'Amazonas', 'Luya', 'Conila', '010505', '0'),
('010406', 'Amazonas', 'Luya', 'Inguilpata', '010506', '0'),
('010407', 'Amazonas', 'Luya', 'Longuita', '010507', '0'),
('010408', 'Amazonas', 'Luya', 'Lonya Chico', '010508', '0'),
('010409', 'Amazonas', 'Luya', 'Luya', '010509', '0'),
('010410', 'Amazonas', 'Luya', 'Luya Viejo', '010510', '0'),
('010411', 'Amazonas', 'Luya', 'Maria', '010511', '0'),
('010412', 'Amazonas', 'Luya', 'Ocalli', '010512', '0'),
('010413', 'Amazonas', 'Luya', 'Ocumal', '010513', '0'),
('010414', 'Amazonas', 'Luya', 'Pisuquia', '010514', '0'),
('010415', 'Amazonas', 'Luya', 'San Cristobal', '010516', '0'),
('010416', 'Amazonas', 'Luya', 'San Francisco De Yeso', '010517', '0'),
('010417', 'Amazonas', 'Luya', 'San Jeronimo', '010518', '0'),
('010418', 'Amazonas', 'Luya', 'San Juan De Lopecancha', '010519', '0'),
('010419', 'Amazonas', 'Luya', 'Santa Catalina', '010520', '0'),
('010420', 'Amazonas', 'Luya', 'Santo Tomas', '010521', '0'),
('010421', 'Amazonas', 'Luya', 'Tingo', '010522', '0'),
('010422', 'Amazonas', 'Luya', 'Trita', '010523', '0'),
('010423', 'Amazonas', 'Luya', 'Providencia', '010515', '0'),
('010501', 'Amazonas', 'Rodriguez De Mendoza', 'San Nicolas', '010601', '0'),
('010502', 'Amazonas', 'Rodriguez De Mendoza', 'Cochamal', '010603', '0'),
('010503', 'Amazonas', 'Rodriguez De Mendoza', 'Chirimoto', '010602', '0'),
('010504', 'Amazonas', 'Rodriguez De Mendoza', 'Huambo', '010604', '0'),
('010505', 'Amazonas', 'Rodriguez De Mendoza', 'Limabamba', '010605', '0'),
('010506', 'Amazonas', 'Rodriguez De Mendoza', 'Longar', '010606', '0'),
('010507', 'Amazonas', 'Rodriguez De Mendoza', 'Milpucc', '010608', '0'),
('010508', 'Amazonas', 'Rodriguez De Mendoza', 'Mariscal Benavides', '010607', '0'),
('010509', 'Amazonas', 'Rodriguez De Mendoza', 'Omia', '010609', '0'),
('010510', 'Amazonas', 'Rodriguez De Mendoza', 'Santa Rosa', '010610', '0'),
('010511', 'Amazonas', 'Rodriguez De Mendoza', 'Totora', '010611', '0'),
('010512', 'Amazonas', 'Rodriguez De Mendoza', 'Vista Alegre', '010612', '0'),
('010601', 'Amazonas', 'Condorcanqui', 'Nieva', '010401', '0'),
('010602', 'Amazonas', 'Condorcanqui', 'Rio Santiago', '010403', '0'),
('010603', 'Amazonas', 'Condorcanqui', 'El Cenepa', '010402', '0'),
('010701', 'Amazonas', 'Utcubamba', 'Bagua Grande', '010701', '0'),
('010702', 'Amazonas', 'Utcubamba', 'Cajaruro', '010702', '0'),
('010703', 'Amazonas', 'Utcubamba', 'Cumba', '010703', '0'),
('010704', 'Amazonas', 'Utcubamba', 'El Milagro', '010704', '0'),
('010705', 'Amazonas', 'Utcubamba', 'Jamalca', '010705', '0'),
('010706', 'Amazonas', 'Utcubamba', 'Lonya Grande', '010706', '0'),
('010707', 'Amazonas', 'Utcubamba', 'Yamon', '010707', '0'),
('020101', 'Ancash', 'Huaraz', 'Huaraz', '020101', '1'),
('020102', 'Ancash', 'Huaraz', 'Independencia', '020105', '1'),
('020103', 'Ancash', 'Huaraz', 'Cochabamba', '020102', '1'),
('020104', 'Ancash', 'Huaraz', 'Colcabamba', '020103', '1'),
('020105', 'Ancash', 'Huaraz', 'Huanchay', '020104', '1'),
('020106', 'Ancash', 'Huaraz', 'Jangas', '020106', '1'),
('020107', 'Ancash', 'Huaraz', 'La Libertad', '020107', '1'),
('020108', 'Ancash', 'Huaraz', 'Olleros', '020108', '1'),
('020109', 'Ancash', 'Huaraz', 'Pampas', '020109', '1'),
('020110', 'Ancash', 'Huaraz', 'Pariacoto', '020110', '1'),
('020111', 'Ancash', 'Huaraz', 'Pira', '020111', '1'),
('020112', 'Ancash', 'Huaraz', 'Tarica', '020112', '1'),
('020201', 'Ancash', 'Aija', 'Aija', '020201', '1'),
('020203', 'Ancash', 'Aija', 'Coris', '020202', '1'),
('020205', 'Ancash', 'Aija', 'Huacllan', '020203', '1'),
('020206', 'Ancash', 'Aija', 'La Merced', '020204', '1'),
('020208', 'Ancash', 'Aija', 'Succha', '020205', '1'),
('020301', 'Ancash', 'Bolognesi', 'Chiquian', '020501', '1'),
('020302', 'Ancash', 'Bolognesi', 'Abelardo Pardo Lezameta', '020502', '1'),
('020304', 'Ancash', 'Bolognesi', 'Aquia', '020504', '1'),
('020305', 'Ancash', 'Bolognesi', 'Cajacay', '020505', '1'),
('020310', 'Ancash', 'Bolognesi', 'Huayllacayan', '020510', '1'),
('020311', 'Ancash', 'Bolognesi', 'Huasta', '020509', '1'),
('020313', 'Ancash', 'Bolognesi', 'Mangas', '020512', '1'),
('020315', 'Ancash', 'Bolognesi', 'Pacllon', '020513', '1'),
('020317', 'Ancash', 'Bolognesi', 'San Miguel De Corpanqui', '020514', '1'),
('020320', 'Ancash', 'Bolognesi', 'Ticllos', '020515', '1'),
('020321', 'Ancash', 'Bolognesi', 'Antonio Raimondi', '020503', '1'),
('020322', 'Ancash', 'Bolognesi', 'Canis', '020506', '1'),
('020323', 'Ancash', 'Bolognesi', 'Colquioc', '020507', '1'),
('020324', 'Ancash', 'Bolognesi', 'La Primavera', '020511', '1'),
('020325', 'Ancash', 'Bolognesi', 'Huallanca', '020508', '1'),
('020401', 'Ancash', 'Carhuaz', 'Carhuaz', '020601', '1'),
('020402', 'Ancash', 'Carhuaz', 'Acopampa', '020602', '1'),
('020403', 'Ancash', 'Carhuaz', 'Amashca', '020603', '1'),
('020404', 'Ancash', 'Carhuaz', 'Anta', '020604', '1'),
('020405', 'Ancash', 'Carhuaz', 'Ataquero', '020605', '1'),
('020406', 'Ancash', 'Carhuaz', 'Marcara', '020606', '1'),
('020407', 'Ancash', 'Carhuaz', 'Pariahuanca', '020607', '1'),
('020408', 'Ancash', 'Carhuaz', 'San Miguel De Aco', '020608', '1'),
('020409', 'Ancash', 'Carhuaz', 'Shilla', '020609', '1'),
('020410', 'Ancash', 'Carhuaz', 'Tinco', '020610', '1'),
('020411', 'Ancash', 'Carhuaz', 'Yungar', '020611', '1'),
('020501', 'Ancash', 'Casma', 'Casma', '020801', '1'),
('020502', 'Ancash', 'Casma', 'Buena Vista Alta', '020802', '1'),
('020503', 'Ancash', 'Casma', 'Comandante Noel', '020803', '1'),
('020505', 'Ancash', 'Casma', 'Yautan', '020804', '1'),
('020601', 'Ancash', 'Corongo', 'Corongo', '020901', '1'),
('020602', 'Ancash', 'Corongo', 'Aco', '020902', '1'),
('020603', 'Ancash', 'Corongo', 'Bambas', '020903', '1'),
('020604', 'Ancash', 'Corongo', 'Cusca', '020904', '1'),
('020605', 'Ancash', 'Corongo', 'La Pampa', '020905', '1'),
('020606', 'Ancash', 'Corongo', 'Yanac', '020906', '1'),
('020607', 'Ancash', 'Corongo', 'Yupan', '020907', '1'),
('020701', 'Ancash', 'Huaylas', 'Caraz', '021201', '1'),
('020702', 'Ancash', 'Huaylas', 'Huallanca', '021202', '1'),
('020703', 'Ancash', 'Huaylas', 'Huata', '021203', '1'),
('020704', 'Ancash', 'Huaylas', 'Huaylas', '021204', '1'),
('020705', 'Ancash', 'Huaylas', 'Mato', '021205', '1'),
('020706', 'Ancash', 'Huaylas', 'Pamparomas', '021206', '1'),
('020707', 'Ancash', 'Huaylas', 'Pueblo Libre', '021207', '1'),
('020708', 'Ancash', 'Huaylas', 'Santa Cruz', '021208', '1'),
('020709', 'Ancash', 'Huaylas', 'Yuracmarca', '021210', '1'),
('020710', 'Ancash', 'Huaylas', 'Santo Toribio', '021209', '1'),
('020801', 'Ancash', 'Huari', 'Huari', '021001', '1'),
('020802', 'Ancash', 'Huari', 'Cajay', '021003', '1'),
('020803', 'Ancash', 'Huari', 'Chavin De Huantar', '021004', '1'),
('020804', 'Ancash', 'Huari', 'Huacachi', '021005', '1'),
('020805', 'Ancash', 'Huari', 'Huachis', '021007', '1'),
('020806', 'Ancash', 'Huari', 'Huacchis', '021006', '1'),
('020807', 'Ancash', 'Huari', 'Huantar', '021008', '1'),
('020808', 'Ancash', 'Huari', 'Masin', '021009', '1'),
('020809', 'Ancash', 'Huari', 'Paucas', '021010', '1'),
('020810', 'Ancash', 'Huari', 'Ponto', '021011', '1'),
('020811', 'Ancash', 'Huari', 'Rahuapampa', '021012', '1'),
('020812', 'Ancash', 'Huari', 'Rapayan', '021013', '1'),
('020813', 'Ancash', 'Huari', 'San Marcos', '021014', '1'),
('020814', 'Ancash', 'Huari', 'San Pedro De Chana', '021015', '1'),
('020815', 'Ancash', 'Huari', 'Uco', '021016', '1'),
('020816', 'Ancash', 'Huari', 'Anra', '021002', '1'),
('020901', 'Ancash', 'Mariscal Luzuriaga', 'Piscobamba', '021301', '1'),
('020902', 'Ancash', 'Mariscal Luzuriaga', 'Casca', '021302', '1'),
('020903', 'Ancash', 'Mariscal Luzuriaga', 'Lucma', '021307', '1'),
('020904', 'Ancash', 'Mariscal Luzuriaga', 'Fidel Olivas Escudero', '021304', '1'),
('020905', 'Ancash', 'Mariscal Luzuriaga', 'Llama', '021305', '1'),
('020906', 'Ancash', 'Mariscal Luzuriaga', 'Llumpa', '021306', '1'),
('020907', 'Ancash', 'Mariscal Luzuriaga', 'Musga', '021308', '1'),
('020908', 'Ancash', 'Mariscal Luzuriaga', 'Eleazar Guzman Barron', '021303', '1'),
('021001', 'Ancash', 'Pallasca', 'Cabana', '021501', '1'),
('021002', 'Ancash', 'Pallasca', 'Bolognesi', '021502', '1'),
('021003', 'Ancash', 'Pallasca', 'Conchucos', '021503', '1'),
('021004', 'Ancash', 'Pallasca', 'Huacaschuque', '021504', '1'),
('021005', 'Ancash', 'Pallasca', 'Huandoval', '021505', '1'),
('021006', 'Ancash', 'Pallasca', 'Lacabamba', '021506', '1'),
('021007', 'Ancash', 'Pallasca', 'Llapo', '021507', '1'),
('021008', 'Ancash', 'Pallasca', 'Pallasca', '021508', '1'),
('021009', 'Ancash', 'Pallasca', 'Pampas', '021509', '1'),
('021010', 'Ancash', 'Pallasca', 'Santa Rosa', '021510', '1'),
('021011', 'Ancash', 'Pallasca', 'Tauca', '021511', '1'),
('021101', 'Ancash', 'Pomabamba', 'Pomabamba', '021601', '1'),
('021102', 'Ancash', 'Pomabamba', 'Huayllan', '021602', '1'),
('021103', 'Ancash', 'Pomabamba', 'Parobamba', '021603', '1'),
('021104', 'Ancash', 'Pomabamba', 'Quinuabamba', '021604', '1'),
('021201', 'Ancash', 'Recuay', 'Recuay', '021701', '1'),
('021202', 'Ancash', 'Recuay', 'Cotaparaco', '021703', '1'),
('021203', 'Ancash', 'Recuay', 'Huayllapampa', '021704', '1'),
('021204', 'Ancash', 'Recuay', 'Marca', '021706', '1'),
('021205', 'Ancash', 'Recuay', 'Pampas Chico', '021707', '1'),
('021206', 'Ancash', 'Recuay', 'Pararin', '021708', '1'),
('021207', 'Ancash', 'Recuay', 'Tapacocha', '021709', '1'),
('021208', 'Ancash', 'Recuay', 'Ticapampa', '021710', '1'),
('021209', 'Ancash', 'Recuay', 'Llacllin', '021705', '1'),
('021210', 'Ancash', 'Recuay', 'Catac', '021702', '1'),
('021301', 'Ancash', 'Santa', 'Chimbote', '021801', '0'),
('021302', 'Ancash', 'Santa', 'Caceres Del Peru', '021802', '0'),
('021303', 'Ancash', 'Santa', 'Macate', '021804', '0'),
('021304', 'Ancash', 'Santa', 'Moro', '021805', '0'),
('021305', 'Ancash', 'Santa', 'Nepeña', '021806', '0'),
('021306', 'Ancash', 'Santa', 'Samanco', '021807', '0'),
('021307', 'Ancash', 'Santa', 'Santa', '021808', '0'),
('021308', 'Ancash', 'Santa', 'Coishco', '021803', '0'),
('021309', 'Ancash', 'Santa', 'Nuevo Chimbote', '021809', '0'),
('021401', 'Ancash', 'Sihuas', 'Sihuas', '021901', '1'),
('021402', 'Ancash', 'Sihuas', 'Alfonso Ugarte', '021903', '1'),
('021403', 'Ancash', 'Sihuas', 'Chingalpo', '021905', '1'),
('021404', 'Ancash', 'Sihuas', 'Huayllabamba', '021906', '1'),
('021405', 'Ancash', 'Sihuas', 'Quiches', '021907', '1'),
('021406', 'Ancash', 'Sihuas', 'Sicsibamba', '021910', '1'),
('021407', 'Ancash', 'Sihuas', 'Acobamba', '021902', '1'),
('021408', 'Ancash', 'Sihuas', 'Cashapampa', '021904', '1'),
('021409', 'Ancash', 'Sihuas', 'Ragash', '021908', '1'),
('021410', 'Ancash', 'Sihuas', 'San Juan', '021909', '1'),
('021501', 'Ancash', 'Yungay', 'Yungay', '022001', '1'),
('021502', 'Ancash', 'Yungay', 'Cascapara', '022002', '1'),
('021503', 'Ancash', 'Yungay', 'Mancos', '022003', '1'),
('021504', 'Ancash', 'Yungay', 'Matacoto', '022004', '1'),
('021505', 'Ancash', 'Yungay', 'Quillo', '022005', '1'),
('021506', 'Ancash', 'Yungay', 'Ranrahirca', '022006', '1'),
('021507', 'Ancash', 'Yungay', 'Shupluy', '022007', '1'),
('021508', 'Ancash', 'Yungay', 'Yanama', '022008', '1'),
('021601', 'Ancash', 'Antonio Raimondi', 'Llamellin', '020301', '1'),
('021602', 'Ancash', 'Antonio Raimondi', 'Aczo', '020302', '1'),
('021603', 'Ancash', 'Antonio Raimondi', 'Chaccho', '020303', '1'),
('021604', 'Ancash', 'Antonio Raimondi', 'Chingas', '020304', '1'),
('021605', 'Ancash', 'Antonio Raimondi', 'Mirgas', '020305', '1'),
('021606', 'Ancash', 'Antonio Raimondi', 'San Juan De Rontoy', '020306', '1'),
('021701', 'Ancash', 'Carlos Fermin Fitzcarrald', 'San Luis', '020701', '1'),
('021702', 'Ancash', 'Carlos Fermin Fitzcarrald', 'Yauya', '020703', '1'),
('021703', 'Ancash', 'Carlos Fermin Fitzcarrald', 'San Nicolas', '020702', '1'),
('021801', 'Ancash', 'Asuncion', 'Chacas', '020401', '1'),
('021802', 'Ancash', 'Asuncion', 'Acochaca', '020402', '1'),
('021901', 'Ancash', 'Huarmey', 'Huarmey', '021101', '1'),
('021902', 'Ancash', 'Huarmey', 'Cochapeti', '021102', '1'),
('021903', 'Ancash', 'Huarmey', 'Huayan', '021104', '1'),
('021904', 'Ancash', 'Huarmey', 'Malvas', '021105', '1'),
('021905', 'Ancash', 'Huarmey', 'Culebras', '021103', '1'),
('022001', 'Ancash', 'Ocros', 'Acas', '021402', '1'),
('022002', 'Ancash', 'Ocros', 'Cajamarquilla', '021403', '1'),
('022003', 'Ancash', 'Ocros', 'Carhuapampa', '021404', '1'),
('022004', 'Ancash', 'Ocros', 'Cochas', '021405', '1'),
('022005', 'Ancash', 'Ocros', 'Congas', '021406', '1'),
('022006', 'Ancash', 'Ocros', 'Llipa', '021407', '1'),
('022007', 'Ancash', 'Ocros', 'Ocros', '021401', '1'),
('022008', 'Ancash', 'Ocros', 'San Cristobal De Rajan', '021408', '1'),
('022009', 'Ancash', 'Ocros', 'San Pedro', '021409', '1'),
('022010', 'Ancash', 'Ocros', 'Santiago De Chilcas', '021410', '1'),
('030101', 'Apurimac', 'Abancay', 'Abancay', '030101', '0'),
('030102', 'Apurimac', 'Abancay', 'Circa', '030103', '0'),
('030103', 'Apurimac', 'Abancay', 'Curahuasi', '030104', '0'),
('030104', 'Apurimac', 'Abancay', 'Chacoche', '030102', '0'),
('030105', 'Apurimac', 'Abancay', 'Huanipaca', '030105', '0'),
('030106', 'Apurimac', 'Abancay', 'Lambrama', '030106', '0'),
('030107', 'Apurimac', 'Abancay', 'Pichirhua', '030107', '0'),
('030108', 'Apurimac', 'Abancay', 'San Pedro De Cachora', '030108', '0'),
('030109', 'Apurimac', 'Abancay', 'Tamburco', '030109', '0'),
('030201', 'Apurimac', 'Aymaraes', 'Chalhuanca', '030401', '0'),
('030202', 'Apurimac', 'Aymaraes', 'Capaya', '030402', '0'),
('030203', 'Apurimac', 'Aymaraes', 'Caraybamba', '030403', '0'),
('030204', 'Apurimac', 'Aymaraes', 'Colcabamba', '030405', '0'),
('030205', 'Apurimac', 'Aymaraes', 'Cotaruse', '030406', '0'),
('030206', 'Apurimac', 'Aymaraes', 'Chapimarca', '030404', '0'),
('030207', 'Apurimac', 'Aymaraes', 'Ihuayllo', '030407', '0'),
('030208', 'Apurimac', 'Aymaraes', 'Lucre', '030409', '0'),
('030209', 'Apurimac', 'Aymaraes', 'Pocohuanca', '030410', '0'),
('030210', 'Apurimac', 'Aymaraes', 'Sañayca', '030412', '0'),
('030211', 'Apurimac', 'Aymaraes', 'Soraya', '030413', '0'),
('030212', 'Apurimac', 'Aymaraes', 'Tapairihua', '030414', '0'),
('030213', 'Apurimac', 'Aymaraes', 'Tintay', '030415', '0'),
('030214', 'Apurimac', 'Aymaraes', 'Toraya', '030416', '0'),
('030215', 'Apurimac', 'Aymaraes', 'Yanaca', '030417', '0'),
('030216', 'Apurimac', 'Aymaraes', 'San Juan De Chacña', '030411', '0'),
('030217', 'Apurimac', 'Aymaraes', 'Justo Apu Sahuaraura', '030408', '0'),
('030301', 'Apurimac', 'Andahuaylas', 'Andahuaylas', '030201', '0'),
('030302', 'Apurimac', 'Andahuaylas', 'Andarapa', '030202', '0'),
('030303', 'Apurimac', 'Andahuaylas', 'Chiara', '030203', '0'),
('030304', 'Apurimac', 'Andahuaylas', 'Huancarama', '030204', '0'),
('030305', 'Apurimac', 'Andahuaylas', 'Huancaray', '030205', '0'),
('030306', 'Apurimac', 'Andahuaylas', 'Kishuara', '030207', '0'),
('030307', 'Apurimac', 'Andahuaylas', 'Pacobamba', '030208', '0'),
('030308', 'Apurimac', 'Andahuaylas', 'Pampachiri', '030210', '0'),
('030309', 'Apurimac', 'Andahuaylas', 'San Antonio De Cachi', '030212', '0'),
('030310', 'Apurimac', 'Andahuaylas', 'San Jeronimo', '030213', '0'),
('030311', 'Apurimac', 'Andahuaylas', 'Talavera', '030216', '0'),
('030312', 'Apurimac', 'Andahuaylas', 'Turpo', '030218', '0'),
('030313', 'Apurimac', 'Andahuaylas', 'Pacucha', '030209', '0'),
('030314', 'Apurimac', 'Andahuaylas', 'Pomacocha', '030211', '0'),
('030315', 'Apurimac', 'Andahuaylas', 'Santa Maria De Chicmo', '030215', '0'),
('030316', 'Apurimac', 'Andahuaylas', 'Tumay Huaraca', '030217', '0'),
('030317', 'Apurimac', 'Andahuaylas', 'Huayana', '030206', '0'),
('030318', 'Apurimac', 'Andahuaylas', 'San Miguel De Chaccrampa', '030214', '0'),
('030319', 'Apurimac', 'Andahuaylas', 'Kaquiabamba', '030219', '0'),
('030401', 'Apurimac', 'Antabamba', 'Antabamba', '030301', '0'),
('030402', 'Apurimac', 'Antabamba', 'El Oro', '030302', '0'),
('030403', 'Apurimac', 'Antabamba', 'Huaquirca', '030303', '0'),
('030404', 'Apurimac', 'Antabamba', 'Juan Espinoza Medrano', '030304', '0'),
('030405', 'Apurimac', 'Antabamba', 'Oropesa', '030305', '0'),
('030406', 'Apurimac', 'Antabamba', 'Pachaconas', '030306', '0'),
('030407', 'Apurimac', 'Antabamba', 'Sabaino', '030307', '0'),
('030501', 'Apurimac', 'Cotabambas', 'Tambobamba', '030501', '0'),
('030502', 'Apurimac', 'Cotabambas', 'Coyllurqui', '030503', '0'),
('030503', 'Apurimac', 'Cotabambas', 'Cotabambas', '030502', '0'),
('030504', 'Apurimac', 'Cotabambas', 'Haquira', '030504', '0'),
('030505', 'Apurimac', 'Cotabambas', 'Mara', '030505', '0'),
('030506', 'Apurimac', 'Cotabambas', 'Challhuahuacho', '030506', '0'),
('030601', 'Apurimac', 'Grau', 'Chuquibambilla', '030701', '0'),
('030602', 'Apurimac', 'Grau', 'Curpahuasi', '030702', '0'),
('030603', 'Apurimac', 'Grau', 'Huayllati', '030704', '0'),
('030604', 'Apurimac', 'Grau', 'Mamara', '030705', '0'),
('030605', 'Apurimac', 'Grau', 'Mariscal Gamarra', '030703', '0'),
('030606', 'Apurimac', 'Grau', 'Micaela Bastidas', '030706', '0'),
('030607', 'Apurimac', 'Grau', 'Progreso', '030708', '0'),
('030608', 'Apurimac', 'Grau', 'Pataypampa', '030707', '0'),
('030609', 'Apurimac', 'Grau', 'San Antonio', '030709', '0'),
('030610', 'Apurimac', 'Grau', 'Turpay', '030711', '0'),
('030611', 'Apurimac', 'Grau', 'Vilcabamba', '030712', '0'),
('030612', 'Apurimac', 'Grau', 'Virundo', '030713', '0'),
('030613', 'Apurimac', 'Grau', 'Santa Rosa', '030710', '0'),
('030614', 'Apurimac', 'Grau', 'Curasco', '030714', '0'),
('030701', 'Apurimac', 'Chincheros', 'Chincheros', '030601', '0'),
('030702', 'Apurimac', 'Chincheros', 'Ongoy', '030606', '0'),
('030703', 'Apurimac', 'Chincheros', 'Ocobamba', '030605', '0'),
('030704', 'Apurimac', 'Chincheros', 'Cocharcas', '030603', '0'),
('030705', 'Apurimac', 'Chincheros', 'Anco Huallo', '030602', '0'),
('030706', 'Apurimac', 'Chincheros', 'Huaccana', '030604', '0'),
('030707', 'Apurimac', 'Chincheros', 'Uranmarca', '030607', '0'),
('030708', 'Apurimac', 'Chincheros', 'Ranracancha', '030608', '0'),
('040101', 'Arequipa', 'Arequipa', 'Arequipa', '040101', '0'),
('040102', 'Arequipa', 'Arequipa', 'Cayma', '040103', '0'),
('040103', 'Arequipa', 'Arequipa', 'Cerro Colorado', '040104', '0'),
('040104', 'Arequipa', 'Arequipa', 'Characato', '040105', '0'),
('040105', 'Arequipa', 'Arequipa', 'Chiguata', '040106', '0'),
('040106', 'Arequipa', 'Arequipa', 'La Joya', '040108', '0'),
('040107', 'Arequipa', 'Arequipa', 'Miraflores', '040110', '0'),
('040108', 'Arequipa', 'Arequipa', 'Mollebaya', '040111', '0'),
('040109', 'Arequipa', 'Arequipa', 'Paucarpata', '040112', '0'),
('040110', 'Arequipa', 'Arequipa', 'Pocsi', '040113', '0'),
('040111', 'Arequipa', 'Arequipa', 'Polobaya', '040114', '0'),
('040112', 'Arequipa', 'Arequipa', 'Quequeña', '040115', '0'),
('040113', 'Arequipa', 'Arequipa', 'Sabandia', '040116', '0'),
('040114', 'Arequipa', 'Arequipa', 'Sachaca', '040117', '0'),
('040115', 'Arequipa', 'Arequipa', 'San Juan De Siguas', '040118', '0'),
('040116', 'Arequipa', 'Arequipa', 'San Juan De Tarucani', '040119', '0'),
('040117', 'Arequipa', 'Arequipa', 'Santa Isabel De Siguas', '040120', '0'),
('040118', 'Arequipa', 'Arequipa', 'Santa Rita De Sihuas', '040121', '0'),
('040119', 'Arequipa', 'Arequipa', 'Socabaya', '040122', '0'),
('040120', 'Arequipa', 'Arequipa', 'Tiabaya', '040123', '0'),
('040121', 'Arequipa', 'Arequipa', 'Uchumayo', '040124', '0'),
('040122', 'Arequipa', 'Arequipa', 'Vitor', '040125', '0'),
('040123', 'Arequipa', 'Arequipa', 'Yanahuara', '040126', '0'),
('040124', 'Arequipa', 'Arequipa', 'Yarabamba', '040127', '0'),
('040125', 'Arequipa', 'Arequipa', 'Yura', '040128', '0'),
('040126', 'Arequipa', 'Arequipa', 'Mariano Melgar', '040109', '0'),
('040127', 'Arequipa', 'Arequipa', 'Jacobo Hunter', '040107', '0'),
('040128', 'Arequipa', 'Arequipa', 'Alto Selva Alegre', '040102', '0'),
('040129', 'Arequipa', 'Arequipa', 'Jose Luis Bustamante Y Rivero', '040129', '0'),
('040201', 'Arequipa', 'Caylloma', 'Chivay', '040501', '0'),
('040202', 'Arequipa', 'Caylloma', 'Achoma', '040502', '0'),
('040203', 'Arequipa', 'Caylloma', 'Cabanaconde', '040503', '0'),
('040204', 'Arequipa', 'Caylloma', 'Caylloma', '040505', '0'),
('040205', 'Arequipa', 'Caylloma', 'Callalli', '040504', '0'),
('040206', 'Arequipa', 'Caylloma', 'Coporaque', '040506', '0'),
('040207', 'Arequipa', 'Caylloma', 'Huambo', '040507', '0'),
('040208', 'Arequipa', 'Caylloma', 'Huanca', '040508', '0'),
('040209', 'Arequipa', 'Caylloma', 'Ichupampa', '040509', '0'),
('040210', 'Arequipa', 'Caylloma', 'Lari', '040510', '0'),
('040211', 'Arequipa', 'Caylloma', 'Lluta', '040511', '0'),
('040212', 'Arequipa', 'Caylloma', 'Maca', '040512', '0'),
('040213', 'Arequipa', 'Caylloma', 'Madrigal', '040513', '0'),
('040214', 'Arequipa', 'Caylloma', 'San Antonio De Chuca', '040514', '0'),
('040215', 'Arequipa', 'Caylloma', 'Sibayo', '040515', '0'),
('040216', 'Arequipa', 'Caylloma', 'Tapay', '040516', '0'),
('040217', 'Arequipa', 'Caylloma', 'Tisco', '040517', '0'),
('040218', 'Arequipa', 'Caylloma', 'Tuti', '040518', '0'),
('040219', 'Arequipa', 'Caylloma', 'Yanque', '040519', '0'),
('040220', 'Arequipa', 'Caylloma', 'Majes', '040520', '0'),
('040301', 'Arequipa', 'Camana', 'Camana', '040201', '0'),
('040302', 'Arequipa', 'Camana', 'Jose Maria Quimper', '040202', '0'),
('040303', 'Arequipa', 'Camana', 'Mariano Nicolas Valcarcel', '040203', '0'),
('040304', 'Arequipa', 'Camana', 'Mariscal Caceres', '040204', '0'),
('040305', 'Arequipa', 'Camana', 'Nicolas De Pierola', '040205', '0'),
('040306', 'Arequipa', 'Camana', 'Ocoña', '040206', '0'),
('040307', 'Arequipa', 'Camana', 'Quilca', '040207', '0'),
('040308', 'Arequipa', 'Camana', 'Samuel Pastor', '040208', '0'),
('040401', 'Arequipa', 'Caraveli', 'Caraveli', '040301', '0'),
('040402', 'Arequipa', 'Caraveli', 'Acari', '040302', '0'),
('040403', 'Arequipa', 'Caraveli', 'Atico', '040303', '0'),
('040404', 'Arequipa', 'Caraveli', 'Atiquipa', '040304', '0'),
('040405', 'Arequipa', 'Caraveli', 'Bella Union', '040305', '0'),
('040406', 'Arequipa', 'Caraveli', 'Cahuacho', '040306', '0'),
('040407', 'Arequipa', 'Caraveli', 'Chala', '040307', '0'),
('040408', 'Arequipa', 'Caraveli', 'Chaparra', '040308', '0'),
('040409', 'Arequipa', 'Caraveli', 'Huanuhuanu', '040309', '0'),
('040410', 'Arequipa', 'Caraveli', 'Jaqui', '040310', '0'),
('040411', 'Arequipa', 'Caraveli', 'Lomas', '040311', '0'),
('040412', 'Arequipa', 'Caraveli', 'Quicacha', '040312', '0'),
('040413', 'Arequipa', 'Caraveli', 'Yauca', '040313', '0'),
('040501', 'Arequipa', 'Castilla', 'Aplao', '040401', '0'),
('040502', 'Arequipa', 'Castilla', 'Andagua', '040402', '0'),
('040503', 'Arequipa', 'Castilla', 'Ayo', '040403', '0'),
('040504', 'Arequipa', 'Castilla', 'Chachas', '040404', '0'),
('040505', 'Arequipa', 'Castilla', 'Chilcaymarca', '040405', '0'),
('040506', 'Arequipa', 'Castilla', 'Choco', '040406', '0'),
('040507', 'Arequipa', 'Castilla', 'Huancarqui', '040407', '0'),
('040508', 'Arequipa', 'Castilla', 'Machaguay', '040408', '0'),
('040509', 'Arequipa', 'Castilla', 'Orcopampa', '040409', '0'),
('040510', 'Arequipa', 'Castilla', 'Pampacolca', '040410', '0'),
('040511', 'Arequipa', 'Castilla', 'Tipan', '040411', '0'),
('040512', 'Arequipa', 'Castilla', 'Uraca', '040413', '0'),
('040513', 'Arequipa', 'Castilla', 'Uñon', '040412', '0'),
('040514', 'Arequipa', 'Castilla', 'Viraco', '040414', '0'),
('040601', 'Arequipa', 'Condesuyos', 'Chuquibamba', '040601', '0'),
('040602', 'Arequipa', 'Condesuyos', 'Andaray', '040602', '0'),
('040603', 'Arequipa', 'Condesuyos', 'Cayarani', '040603', '0'),
('040604', 'Arequipa', 'Condesuyos', 'Chichas', '040604', '0'),
('040605', 'Arequipa', 'Condesuyos', 'Iray', '040605', '0'),
('040606', 'Arequipa', 'Condesuyos', 'Salamanca', '040607', '0'),
('040607', 'Arequipa', 'Condesuyos', 'Yanaquihua', '040608', '0'),
('040608', 'Arequipa', 'Condesuyos', 'Rio Grande', '040606', '0'),
('040701', 'Arequipa', 'Islay', 'Mollendo', '040701', '0'),
('040702', 'Arequipa', 'Islay', 'Cocachacra', '040702', '0'),
('040703', 'Arequipa', 'Islay', 'Dean Valdivia', '040703', '0'),
('040704', 'Arequipa', 'Islay', 'Islay', '040704', '0'),
('040705', 'Arequipa', 'Islay', 'Mejia', '040705', '0'),
('040706', 'Arequipa', 'Islay', 'Punta De Bombon', '040706', '0'),
('040801', 'Arequipa', 'La Union', 'Cotahuasi', '040801', '0'),
('040802', 'Arequipa', 'La Union', 'Alca', '040802', '0'),
('040803', 'Arequipa', 'La Union', 'Charcana', '040803', '0'),
('040804', 'Arequipa', 'La Union', 'Huaynacotas', '040804', '0'),
('040805', 'Arequipa', 'La Union', 'Pampamarca', '040805', '0'),
('040806', 'Arequipa', 'La Union', 'Puyca', '040806', '0'),
('040807', 'Arequipa', 'La Union', 'Quechualla', '040807', '0'),
('040808', 'Arequipa', 'La Union', 'Sayla', '040808', '0'),
('040809', 'Arequipa', 'La Union', 'Tauria', '040809', '0'),
('040810', 'Arequipa', 'La Union', 'Tomepampa', '040810', '0'),
('040811', 'Arequipa', 'La Union', 'Toro', '040811', '0'),
('050101', 'Ayacucho', 'Huamanga', 'Ayacucho', '050101', '0'),
('050102', 'Ayacucho', 'Huamanga', 'Acos Vinchos', '050103', '0'),
('050103', 'Ayacucho', 'Huamanga', 'Carmen Alto', '050104', '0'),
('050104', 'Ayacucho', 'Huamanga', 'Chiara', '050105', '0'),
('050105', 'Ayacucho', 'Huamanga', 'Quinua', '050108', '0'),
('050106', 'Ayacucho', 'Huamanga', 'San Jose De Ticllas', '050109', '0'),
('050107', 'Ayacucho', 'Huamanga', 'San Juan Bautista', '050110', '0'),
('050108', 'Ayacucho', 'Huamanga', 'Santiago De Pischa', '050111', '0'),
('050109', 'Ayacucho', 'Huamanga', 'Vinchos', '050114', '0'),
('050110', 'Ayacucho', 'Huamanga', 'Tambillo', '050113', '0'),
('050111', 'Ayacucho', 'Huamanga', 'Acocro', '050102', '0'),
('050112', 'Ayacucho', 'Huamanga', 'Socos', '050112', '0'),
('050113', 'Ayacucho', 'Huamanga', 'Ocros', '050106', '0'),
('050114', 'Ayacucho', 'Huamanga', 'Pacaycasa', '050107', '0'),
('050115', 'Ayacucho', 'Huamanga', 'Jesus Nazareno', '050115', '0'),
('050201', 'Ayacucho', 'Cangallo', 'Cangallo', '050201', '0'),
('050204', 'Ayacucho', 'Cangallo', 'Chuschi', '050202', '0'),
('050206', 'Ayacucho', 'Cangallo', 'Los Morochucos', '050203', '0'),
('050207', 'Ayacucho', 'Cangallo', 'Paras', '050205', '0'),
('050208', 'Ayacucho', 'Cangallo', 'Totos', '050206', '0'),
('050211', 'Ayacucho', 'Cangallo', 'Maria Parado De Bellido', '050204', '0'),
('050301', 'Ayacucho', 'Huanta', 'Huanta', '050401', '0'),
('050302', 'Ayacucho', 'Huanta', 'Ayahuanco', '050402', '0'),
('050303', 'Ayacucho', 'Huanta', 'Huamanguilla', '050403', '0'),
('050304', 'Ayacucho', 'Huanta', 'Iguain', '050404', '0'),
('050305', 'Ayacucho', 'Huanta', 'Luricocha', '050405', '0'),
('050307', 'Ayacucho', 'Huanta', 'Santillana', '050406', '0'),
('050308', 'Ayacucho', 'Huanta', 'Sivia', '050407', '0'),
('050309', 'Ayacucho', 'Huanta', 'Llochegua', '050408', '0'),
('050401', 'Ayacucho', 'La Mar', 'San Miguel', '050501', '0'),
('050402', 'Ayacucho', 'La Mar', 'Anco', '050502', '0'),
('050403', 'Ayacucho', 'La Mar', 'Ayna', '050503', '0'),
('050404', 'Ayacucho', 'La Mar', 'Chilcas', '050504', '0'),
('050405', 'Ayacucho', 'La Mar', 'Chungui', '050505', '0'),
('050406', 'Ayacucho', 'La Mar', 'Tambo', '050508', '0'),
('050407', 'Ayacucho', 'La Mar', 'Luis Carranza', '050506', '0'),
('050408', 'Ayacucho', 'La Mar', 'Santa Rosa', '050507', '0'),
('050501', 'Ayacucho', 'Lucanas', 'Puquio', '050601', '0'),
('050502', 'Ayacucho', 'Lucanas', 'Aucara', '050602', '0'),
('050503', 'Ayacucho', 'Lucanas', 'Cabana', '050603', '0'),
('050504', 'Ayacucho', 'Lucanas', 'Carmen Salcedo', '050604', '0'),
('050506', 'Ayacucho', 'Lucanas', 'Chaviña', '050605', '0'),
('050508', 'Ayacucho', 'Lucanas', 'Chipao', '050606', '0'),
('050510', 'Ayacucho', 'Lucanas', 'Huac-huas', '050607', '0'),
('050511', 'Ayacucho', 'Lucanas', 'Laramate', '050608', '0'),
('050512', 'Ayacucho', 'Lucanas', 'Leoncio Prado', '050609', '0'),
('050513', 'Ayacucho', 'Lucanas', 'Lucanas', '050611', '0'),
('050514', 'Ayacucho', 'Lucanas', 'Llauta', '050610', '0'),
('050516', 'Ayacucho', 'Lucanas', 'Ocaña', '050612', '0'),
('050517', 'Ayacucho', 'Lucanas', 'Otoca', '050613', '0'),
('050520', 'Ayacucho', 'Lucanas', 'Sancos', '050619', '0'),
('050521', 'Ayacucho', 'Lucanas', 'San Juan', '050616', '0'),
('050522', 'Ayacucho', 'Lucanas', 'San Pedro', '050617', '0'),
('050524', 'Ayacucho', 'Lucanas', 'Santa Ana De Huaycahuacho', '050620', '0'),
('050525', 'Ayacucho', 'Lucanas', 'Santa Lucia', '050621', '0'),
('050529', 'Ayacucho', 'Lucanas', 'Saisa', '050614', '0'),
('050531', 'Ayacucho', 'Lucanas', 'San Pedro De Palco', '050618', '0'),
('050532', 'Ayacucho', 'Lucanas', 'San Cristobal', '050615', '0'),
('050601', 'Ayacucho', 'Parinacochas', 'Coracora', '050701', '0'),
('050604', 'Ayacucho', 'Parinacochas', 'Coronel Castañeda', '050703', '0'),
('050605', 'Ayacucho', 'Parinacochas', 'Chumpi', '050702', '0'),
('050608', 'Ayacucho', 'Parinacochas', 'Pacapausa', '050704', '0'),
('050611', 'Ayacucho', 'Parinacochas', 'Pullo', '050705', '0'),
('050612', 'Ayacucho', 'Parinacochas', 'Puyusca', '050706', '0'),
('050615', 'Ayacucho', 'Parinacochas', 'San Francisco De Ravacayco', '050707', '0'),
('050616', 'Ayacucho', 'Parinacochas', 'Upahuacho', '050708', '0'),
('050701', 'Ayacucho', 'Victor Fajardo', 'Huancapi', '051001', '0'),
('050702', 'Ayacucho', 'Victor Fajardo', 'Alcamenca', '051002', '0'),
('050703', 'Ayacucho', 'Victor Fajardo', 'Apongo', '051003', '0'),
('050704', 'Ayacucho', 'Victor Fajardo', 'Canaria', '051005', '0'),
('050706', 'Ayacucho', 'Victor Fajardo', 'Cayara', '051006', '0'),
('050707', 'Ayacucho', 'Victor Fajardo', 'Colca', '051007', '0'),
('050708', 'Ayacucho', 'Victor Fajardo', 'Huaya', '051010', '0'),
('050709', 'Ayacucho', 'Victor Fajardo', 'Huamanquiquia', '051008', '0'),
('050710', 'Ayacucho', 'Victor Fajardo', 'Huancaraylla', '051009', '0'),
('050713', 'Ayacucho', 'Victor Fajardo', 'Sarhua', '051011', '0'),
('050714', 'Ayacucho', 'Victor Fajardo', 'Vilcanchos', '051012', '0'),
('050715', 'Ayacucho', 'Victor Fajardo', 'Asquipata', '051004', '0'),
('050801', 'Ayacucho', 'Huanca Sancos', 'Sancos', '050301', '0'),
('050802', 'Ayacucho', 'Huanca Sancos', 'Sacsamarca', '050303', '0'),
('050803', 'Ayacucho', 'Huanca Sancos', 'Santiago De Lucanamarca', '050304', '0'),
('050804', 'Ayacucho', 'Huanca Sancos', 'Carapo', '050302', '0'),
('050901', 'Ayacucho', 'Vilcas Huaman', 'Vilcas Huaman', '051101', '0'),
('050902', 'Ayacucho', 'Vilcas Huaman', 'Vischongo', '051108', '0'),
('050903', 'Ayacucho', 'Vilcas Huaman', 'Accomarca', '051102', '0'),
('050904', 'Ayacucho', 'Vilcas Huaman', 'Carhuanca', '051103', '0'),
('050905', 'Ayacucho', 'Vilcas Huaman', 'Concepcion', '051104', '0'),
('050906', 'Ayacucho', 'Vilcas Huaman', 'Huambalpa', '051105', '0'),
('050907', 'Ayacucho', 'Vilcas Huaman', 'Saurama', '051107', '0'),
('050908', 'Ayacucho', 'Vilcas Huaman', 'Independencia', '051106', '0'),
('051001', 'Ayacucho', 'Paucar Del Sara Sara', 'Pausa', '050801', '0'),
('051002', 'Ayacucho', 'Paucar Del Sara Sara', 'Colta', '050802', '0'),
('051003', 'Ayacucho', 'Paucar Del Sara Sara', 'Corculla', '050803', '0'),
('051004', 'Ayacucho', 'Paucar Del Sara Sara', 'Lampa', '050804', '0'),
('051005', 'Ayacucho', 'Paucar Del Sara Sara', 'Marcabamba', '050805', '0'),
('051006', 'Ayacucho', 'Paucar Del Sara Sara', 'Oyolo', '050806', '0'),
('051007', 'Ayacucho', 'Paucar Del Sara Sara', 'Pararca', '050807', '0'),
('051008', 'Ayacucho', 'Paucar Del Sara Sara', 'San Javier De Alpabamba', '050808', '0'),
('051009', 'Ayacucho', 'Paucar Del Sara Sara', 'San Jose De Ushua', '050809', '0'),
('051010', 'Ayacucho', 'Paucar Del Sara Sara', 'Sara Sara', '050810', '0'),
('051101', 'Ayacucho', 'Sucre', 'Querobamba', '050901', '0'),
('051102', 'Ayacucho', 'Sucre', 'Belen', '050902', '0'),
('051103', 'Ayacucho', 'Sucre', 'Chalcos', '050903', '0'),
('051104', 'Ayacucho', 'Sucre', 'San Salvador De Quije', '050909', '0'),
('051105', 'Ayacucho', 'Sucre', 'Paico', '050907', '0'),
('051106', 'Ayacucho', 'Sucre', 'Santiago De Paucaray', '050910', '0'),
('051107', 'Ayacucho', 'Sucre', 'San Pedro De Larcay', '050908', '0'),
('051108', 'Ayacucho', 'Sucre', 'Soras', '050911', '0'),
('051109', 'Ayacucho', 'Sucre', 'Huacaña', '050905', '0'),
('051110', 'Ayacucho', 'Sucre', 'Chilcayoc', '050904', '0'),
('051111', 'Ayacucho', 'Sucre', 'Morcolla', '050906', '0'),
('060101', 'Cajamarca', 'Cajamarca', 'Cajamarca', '060101', '0'),
('060102', 'Cajamarca', 'Cajamarca', 'Asuncion', '060102', '0'),
('060103', 'Cajamarca', 'Cajamarca', 'Cospan', '060104', '0'),
('060104', 'Cajamarca', 'Cajamarca', 'Chetilla', '060103', '0'),
('060105', 'Cajamarca', 'Cajamarca', 'Encañada', '060105', '0'),
('060106', 'Cajamarca', 'Cajamarca', 'Jesus', '060106', '0'),
('060107', 'Cajamarca', 'Cajamarca', 'Los Baños Del Inca', '060108', '0'),
('060108', 'Cajamarca', 'Cajamarca', 'Llacanora', '060107', '0'),
('060109', 'Cajamarca', 'Cajamarca', 'Magdalena', '060109', '0'),
('060110', 'Cajamarca', 'Cajamarca', 'Matara', '060110', '0'),
('060111', 'Cajamarca', 'Cajamarca', 'Namora', '060111', '0'),
('060112', 'Cajamarca', 'Cajamarca', 'San Juan', '060112', '0'),
('060201', 'Cajamarca', 'Cajabamba', 'Cajabamba', '060201', '1'),
('060202', 'Cajamarca', 'Cajabamba', 'Cachachi', '060202', '1'),
('060203', 'Cajamarca', 'Cajabamba', 'Condebamba', '060203', '1'),
('060205', 'Cajamarca', 'Cajabamba', 'Sitacocha', '060204', '1'),
('060301', 'Cajamarca', 'Celendin', 'Celendin', '060301', '1'),
('060302', 'Cajamarca', 'Celendin', 'Cortegana', '060303', '1'),
('060303', 'Cajamarca', 'Celendin', 'Chumuch', '060302', '1'),
('060304', 'Cajamarca', 'Celendin', 'Huasmin', '060304', '1'),
('060305', 'Cajamarca', 'Celendin', 'Jorge Chavez', '060305', '1'),
('060306', 'Cajamarca', 'Celendin', 'Jose Galvez', '060306', '1'),
('060307', 'Cajamarca', 'Celendin', 'Miguel Iglesias', '060307', '1'),
('060308', 'Cajamarca', 'Celendin', 'Oxamarca', '060308', '1'),
('060309', 'Cajamarca', 'Celendin', 'Sorochuco', '060309', '1'),
('060310', 'Cajamarca', 'Celendin', 'Sucre', '060310', '1'),
('060311', 'Cajamarca', 'Celendin', 'Utco', '060311', '1'),
('060312', 'Cajamarca', 'Celendin', 'La Libertad De Pallan', '060312', '1'),
('060401', 'Cajamarca', 'Contumaza', 'Contumaza', '060501', '1'),
('060403', 'Cajamarca', 'Contumaza', 'Chilete', '060502', '1'),
('060404', 'Cajamarca', 'Contumaza', 'Guzmango', '060504', '1'),
('060405', 'Cajamarca', 'Contumaza', 'San Benito', '060505', '1'),
('060406', 'Cajamarca', 'Contumaza', 'Cupisnique', '060503', '1'),
('060407', 'Cajamarca', 'Contumaza', 'Tantarica', '060507', '1'),
('060408', 'Cajamarca', 'Contumaza', 'Yonan', '060508', '1'),
('060409', 'Cajamarca', 'Contumaza', 'Santa Cruz De Toled', '060506', '1'),
('060501', 'Cajamarca', 'Cutervo', 'Cutervo', '060601', '1'),
('060502', 'Cajamarca', 'Cutervo', 'Callayuc', '060602', '1'),
('060503', 'Cajamarca', 'Cutervo', 'Cujillo', '060604', '1'),
('060504', 'Cajamarca', 'Cutervo', 'Choros', '060603', '1'),
('060505', 'Cajamarca', 'Cutervo', 'La Ramada', '060605', '1'),
('060506', 'Cajamarca', 'Cutervo', 'Pimpingos', '060606', '1'),
('060507', 'Cajamarca', 'Cutervo', 'Querocotillo', '060607', '1'),
('060508', 'Cajamarca', 'Cutervo', 'San Andres De Cutervo', '060608', '1'),
('060509', 'Cajamarca', 'Cutervo', 'San Juan De Cutervo', '060609', '1'),
('060510', 'Cajamarca', 'Cutervo', 'San Luis De Lucma', '060610', '1'),
('060511', 'Cajamarca', 'Cutervo', 'Santa Cruz', '060611', '1'),
('060512', 'Cajamarca', 'Cutervo', 'Santo Domingo De La Capilla', '060612', '1'),
('060513', 'Cajamarca', 'Cutervo', 'Santo Tomas', '060613', '1'),
('060514', 'Cajamarca', 'Cutervo', 'Socota', '060614', '1'),
('060515', 'Cajamarca', 'Cutervo', 'Toribio Casanova', '060615', '1'),
('060601', 'Cajamarca', 'Chota', 'Chota', '060401', '1'),
('060602', 'Cajamarca', 'Chota', 'Anguia', '060402', '1'),
('060603', 'Cajamarca', 'Chota', 'Cochabamba', '060407', '1'),
('060604', 'Cajamarca', 'Chota', 'Conchan', '060408', '1'),
('060605', 'Cajamarca', 'Chota', 'Chadin', '060403', '1'),
('060606', 'Cajamarca', 'Chota', 'Chiguirip', '060404', '1'),
('060607', 'Cajamarca', 'Chota', 'Chimban', '060405', '1'),
('060608', 'Cajamarca', 'Chota', 'Huambos', '060409', '1'),
('060609', 'Cajamarca', 'Chota', 'Lajas', '060410', '1'),
('060610', 'Cajamarca', 'Chota', 'Llama', '060411', '1'),
('060611', 'Cajamarca', 'Chota', 'Miracosta', '060412', '1'),
('060612', 'Cajamarca', 'Chota', 'Paccha', '060413', '1'),
('060613', 'Cajamarca', 'Chota', 'Pion', '060414', '1'),
('060614', 'Cajamarca', 'Chota', 'Querocoto', '060415', '1'),
('060615', 'Cajamarca', 'Chota', 'Tacabamba', '060417', '1'),
('060616', 'Cajamarca', 'Chota', 'Tocmoche', '060418', '1'),
('060617', 'Cajamarca', 'Chota', 'San Juan De Licupis', '060416', '1'),
('060618', 'Cajamarca', 'Chota', 'Choropampa', '060406', '1'),
('060619', 'Cajamarca', 'Chota', 'Chalamarca', '060419', '1'),
('060701', 'Cajamarca', 'Hualgayoc', 'Bambamarca', '060701', '1'),
('060702', 'Cajamarca', 'Hualgayoc', 'Chugur', '060702', '1'),
('060703', 'Cajamarca', 'Hualgayoc', 'Hualgayoc', '060703', '1'),
('060801', 'Cajamarca', 'Jaen', 'Jaen', '060801', '1'),
('060802', 'Cajamarca', 'Jaen', 'Bellavista', '060802', '1'),
('060803', 'Cajamarca', 'Jaen', 'Colasay', '060804', '1'),
('060804', 'Cajamarca', 'Jaen', 'Chontali', '060803', '1'),
('060805', 'Cajamarca', 'Jaen', 'Pomahuaca', '060807', '1'),
('060806', 'Cajamarca', 'Jaen', 'Pucara', '060808', '1'),
('060807', 'Cajamarca', 'Jaen', 'Sallique', '060809', '1'),
('060808', 'Cajamarca', 'Jaen', 'San Felipe', '060810', '1'),
('060809', 'Cajamarca', 'Jaen', 'San Jose Del Alto', '060811', '1'),
('060810', 'Cajamarca', 'Jaen', 'Santa Rosa', '060812', '1'),
('060811', 'Cajamarca', 'Jaen', 'Las Pirias', '060806', '1'),
('060812', 'Cajamarca', 'Jaen', 'Huabal', '060805', '1'),
('060901', 'Cajamarca', 'Santa Cruz', 'Santa Cruz', '061301', '1'),
('060902', 'Cajamarca', 'Santa Cruz', 'Catache', '061303', '1'),
('060903', 'Cajamarca', 'Santa Cruz', 'Chancaybaños', '061304', '1'),
('060904', 'Cajamarca', 'Santa Cruz', 'La Esperanza', '061305', '1'),
('060905', 'Cajamarca', 'Santa Cruz', 'Ninabamba', '061306', '1'),
('060906', 'Cajamarca', 'Santa Cruz', 'Pulan', '061307', '1'),
('060907', 'Cajamarca', 'Santa Cruz', 'Sexi', '061309', '1'),
('060908', 'Cajamarca', 'Santa Cruz', 'Uticyacu', '061310', '1'),
('060909', 'Cajamarca', 'Santa Cruz', 'Yauyucan', '061311', '1'),
('060910', 'Cajamarca', 'Santa Cruz', 'Andabamba', '061302', '1'),
('060911', 'Cajamarca', 'Santa Cruz', 'Saucepampa', '061308', '1'),
('061001', 'Cajamarca', 'San Miguel', 'San Miguel', '061101', '1'),
('061002', 'Cajamarca', 'San Miguel', 'Calquis', '061103', '1'),
('061003', 'Cajamarca', 'San Miguel', 'La Florida', '061106', '1'),
('061004', 'Cajamarca', 'San Miguel', 'Llapa', '061107', '1'),
('061005', 'Cajamarca', 'San Miguel', 'Nanchoc', '061108', '1'),
('061006', 'Cajamarca', 'San Miguel', 'Niepos', '061109', '1'),
('061007', 'Cajamarca', 'San Miguel', 'San Gregorio', '061110', '1'),
('061008', 'Cajamarca', 'San Miguel', 'San Silvestre De Cochan', '061111', '1'),
('061009', 'Cajamarca', 'San Miguel', 'El Prado', '061105', '1'),
('061010', 'Cajamarca', 'San Miguel', 'Union Agua Blanca', '061113', '1'),
('061011', 'Cajamarca', 'San Miguel', 'Tongod', '061112', '1'),
('061012', 'Cajamarca', 'San Miguel', 'Catilluc', '061104', '1'),
('061013', 'Cajamarca', 'San Miguel', 'Bolivar', '061102', '1'),
('061101', 'Cajamarca', 'San Ignacio', 'San Ignacio', '060901', '1'),
('061102', 'Cajamarca', 'San Ignacio', 'Chirinos', '060902', '1'),
('061103', 'Cajamarca', 'San Ignacio', 'Huarango', '060903', '1'),
('061104', 'Cajamarca', 'San Ignacio', 'Namballe', '060905', '1'),
('061105', 'Cajamarca', 'San Ignacio', 'La Coipa', '060904', '1'),
('061106', 'Cajamarca', 'San Ignacio', 'San Jose De Lourdes', '060906', '1'),
('061107', 'Cajamarca', 'San Ignacio', 'Tabaconas', '060907', '1'),
('061201', 'Cajamarca', 'San Marcos', 'Pedro Galvez', '061001', '1'),
('061202', 'Cajamarca', 'San Marcos', 'Ichocan', '061005', '1'),
('061203', 'Cajamarca', 'San Marcos', 'Gregorio Pita', '061004', '1'),
('061204', 'Cajamarca', 'San Marcos', 'Jose Manuel Quiroz', '061006', '1'),
('061205', 'Cajamarca', 'San Marcos', 'Eduardo Villanueva', '061003', '1'),
('061206', 'Cajamarca', 'San Marcos', 'Jose Sabogal', '061007', '1'),
('061207', 'Cajamarca', 'San Marcos', 'Chancay', '061002', '1'),
('061301', 'Cajamarca', 'San Pablo', 'San Pablo', '061201', '1'),
('061302', 'Cajamarca', 'San Pablo', 'San Bernardino', '061202', '1'),
('061303', 'Cajamarca', 'San Pablo', 'San Luis', '061203', '1'),
('061304', 'Cajamarca', 'San Pablo', 'Tumbaden', '061204', '1'),
('070101', 'Cusco', 'Cusco', 'Cusco', '080101', '0'),
('070102', 'Cusco', 'Cusco', 'Ccorca', '080102', '0'),
('070103', 'Cusco', 'Cusco', 'Poroy', '080103', '0'),
('070104', 'Cusco', 'Cusco', 'San Jeronimo', '080104', '0'),
('070105', 'Cusco', 'Cusco', 'San Sebastian', '080105', '0'),
('070106', 'Cusco', 'Cusco', 'Santiago', '080106', '0'),
('070107', 'Cusco', 'Cusco', 'Saylla', '080107', '0'),
('070108', 'Cusco', 'Cusco', 'Wanchaq', '080108', '0'),
('070201', 'Cusco', 'Acomayo', 'Acomayo', '080201', '1'),
('070202', 'Cusco', 'Acomayo', 'Acopia', '080202', '1'),
('070203', 'Cusco', 'Acomayo', 'Acos', '080203', '1'),
('070204', 'Cusco', 'Acomayo', 'Pomacanchi', '080205', '1'),
('070205', 'Cusco', 'Acomayo', 'Rondocan', '080206', '1'),
('070206', 'Cusco', 'Acomayo', 'Sangarara', '080207', '1'),
('070207', 'Cusco', 'Acomayo', 'Mosoc Llacta', '080204', '1'),
('070301', 'Cusco', 'Anta', 'Anta', '080301', '1'),
('070302', 'Cusco', 'Anta', 'Chinchaypujio', '080304', '1'),
('070303', 'Cusco', 'Anta', 'Huarocondo', '080305', '1'),
('070304', 'Cusco', 'Anta', 'Limatambo', '080306', '1'),
('070305', 'Cusco', 'Anta', 'Mollepata', '080307', '1'),
('070306', 'Cusco', 'Anta', 'Pucyura', '080308', '1'),
('070307', 'Cusco', 'Anta', 'Zurite', '080309', '1'),
('070308', 'Cusco', 'Anta', 'Cachimayo', '080303', '1'),
('070309', 'Cusco', 'Anta', 'Ancahuasi', '080302', '1'),
('070401', 'Cusco', 'Calca', 'Calca', '080401', '1'),
('070402', 'Cusco', 'Calca', 'Coya', '080402', '1'),
('070403', 'Cusco', 'Calca', 'Lamay', '080403', '1'),
('070404', 'Cusco', 'Calca', 'Lares', '080404', '1'),
('070405', 'Cusco', 'Calca', 'Pisac', '080405', '1'),
('070406', 'Cusco', 'Calca', 'San Salvador', '080406', '1'),
('070407', 'Cusco', 'Calca', 'Taray', '080407', '1'),
('070408', 'Cusco', 'Calca', 'Yanatile', '080408', '1'),
('070501', 'Cusco', 'Canas', 'Yanaoca', '080501', '1'),
('070502', 'Cusco', 'Canas', 'Checca', '080502', '1'),
('070503', 'Cusco', 'Canas', 'Kunturkanki', '080503', '1'),
('070504', 'Cusco', 'Canas', 'Langui', '080504', '1'),
('070505', 'Cusco', 'Canas', 'Layo', '080505', '1'),
('070506', 'Cusco', 'Canas', 'Pampamarca', '080506', '1'),
('070507', 'Cusco', 'Canas', 'Quehue', '080507', '1'),
('070508', 'Cusco', 'Canas', 'Tupac Amaru', '080508', '1'),
('070601', 'Cusco', 'Canchis', 'Sicuani', '080601', '1'),
('070602', 'Cusco', 'Canchis', 'Combapata', '080603', '1'),
('070603', 'Cusco', 'Canchis', 'Checacupe', '080602', '1'),
('070604', 'Cusco', 'Canchis', 'Marangani', '080604', '1'),
('070605', 'Cusco', 'Canchis', 'Pitumarca', '080605', '1'),
('070606', 'Cusco', 'Canchis', 'San Pablo', '080606', '1'),
('070607', 'Cusco', 'Canchis', 'San Pedro', '080607', '1'),
('070608', 'Cusco', 'Canchis', 'Tinta', '080608', '1'),
('070701', 'Cusco', 'Chumbivilcas', 'Santo Tomas', '080701', '1'),
('070702', 'Cusco', 'Chumbivilcas', 'Capacmarca', '080702', '1'),
('070703', 'Cusco', 'Chumbivilcas', 'Colquemarca', '080704', '1'),
('070704', 'Cusco', 'Chumbivilcas', 'Chamaca', '080703', '1'),
('070705', 'Cusco', 'Chumbivilcas', 'Livitaca', '080705', '1'),
('070706', 'Cusco', 'Chumbivilcas', 'Llusco', '080706', '1'),
('070707', 'Cusco', 'Chumbivilcas', 'Quiñota', '080707', '1'),
('070708', 'Cusco', 'Chumbivilcas', 'Velille', '080708', '1'),
('070801', 'Cusco', 'Espinar', 'Espinar', '080801', '1'),
('070802', 'Cusco', 'Espinar', 'Condoroma', '080802', '1'),
('070803', 'Cusco', 'Espinar', 'Coporaque', '080803', '1'),
('070804', 'Cusco', 'Espinar', 'Occoruro', '080804', '1'),
('070805', 'Cusco', 'Espinar', 'Pallpata', '080805', '1'),
('070806', 'Cusco', 'Espinar', 'Pichigua', '080806', '1'),
('070807', 'Cusco', 'Espinar', 'Suyckutambo', '080807', '1'),
('070808', 'Cusco', 'Espinar', 'Alto Pichigua', '080808', '1'),
('070901', 'Cusco', 'La Convencion', 'Santa Ana', '080901', '1'),
('070902', 'Cusco', 'La Convencion', 'Echarati', '080902', '1'),
('070903', 'Cusco', 'La Convencion', 'Huayopata', '080903', '1'),
('070904', 'Cusco', 'La Convencion', 'Maranura', '080904', '1'),
('070905', 'Cusco', 'La Convencion', 'Ocobamba', '080905', '1'),
('070906', 'Cusco', 'La Convencion', 'Santa Teresa', '080908', '1'),
('070907', 'Cusco', 'La Convencion', 'Vilcabamba', '080909', '1'),
('070908', 'Cusco', 'La Convencion', 'Quellouno', '080906', '1'),
('070909', 'Cusco', 'La Convencion', 'Kimbiri', '080907', '1'),
('070910', 'Cusco', 'La Convencion', 'Pichari', '080910', '1'),
('071001', 'Cusco', 'Paruro', 'Paruro', '081001', '1'),
('071002', 'Cusco', 'Paruro', 'Accha', '081002', '1'),
('071003', 'Cusco', 'Paruro', 'Ccapi', '081003', '1'),
('071004', 'Cusco', 'Paruro', 'Colcha', '081004', '1'),
('071005', 'Cusco', 'Paruro', 'Huanoquite', '081005', '1'),
('071006', 'Cusco', 'Paruro', 'Omacha', '081006', '1'),
('071007', 'Cusco', 'Paruro', 'Yaurisque', '081009', '1'),
('071008', 'Cusco', 'Paruro', 'Paccaritambo', '081007', '1'),
('071009', 'Cusco', 'Paruro', 'Pillpinto', '081008', '1'),
('071101', 'Cusco', 'Paucartambo', 'Paucartambo', '081101', '1'),
('071102', 'Cusco', 'Paucartambo', 'Caicay', '081102', '1'),
('071103', 'Cusco', 'Paucartambo', 'Colquepata', '081104', '1'),
('071104', 'Cusco', 'Paucartambo', 'Challabamba', '081103', '1'),
('071105', 'Cusco', 'Paucartambo', 'Kosñipata', '081106', '1'),
('071106', 'Cusco', 'Paucartambo', 'Huancarani', '081105', '1'),
('071201', 'Cusco', 'Quispicanchi', 'Urcos', '081201', '1'),
('071202', 'Cusco', 'Quispicanchi', 'Andahuaylillas', '081202', '1'),
('071203', 'Cusco', 'Quispicanchi', 'Camanti', '081203', '1'),
('071204', 'Cusco', 'Quispicanchi', 'Ccarhuayo', '081204', '1'),
('071205', 'Cusco', 'Quispicanchi', 'Ccatca', '081205', '1'),
('071206', 'Cusco', 'Quispicanchi', 'Cusipata', '081206', '1'),
('071207', 'Cusco', 'Quispicanchi', 'Huaro', '081207', '1'),
('071208', 'Cusco', 'Quispicanchi', 'Lucre', '081208', '1'),
('071209', 'Cusco', 'Quispicanchi', 'Marcapata', '081209', '1'),
('071210', 'Cusco', 'Quispicanchi', 'Ocongate', '081210', '1'),
('071211', 'Cusco', 'Quispicanchi', 'Oropesa', '081211', '1'),
('071212', 'Cusco', 'Quispicanchi', 'Quiquijana', '081212', '1'),
('071301', 'Cusco', 'Urubamba', 'Urubamba', '081301', '1'),
('071302', 'Cusco', 'Urubamba', 'Chinchero', '081302', '1'),
('071303', 'Cusco', 'Urubamba', 'Huayllabamba', '081303', '1'),
('071304', 'Cusco', 'Urubamba', 'Machupicchu', '081304', '1'),
('071305', 'Cusco', 'Urubamba', 'Maras', '081305', '1'),
('071306', 'Cusco', 'Urubamba', 'Ollantaytambo', '081306', '1'),
('071307', 'Cusco', 'Urubamba', 'Yucay', '081307', '1'),
('080101', 'Huancavelica', 'Huancavelica', 'Huancavelica', '090101', '0'),
('080102', 'Huancavelica', 'Huancavelica', 'Acobambilla', '090102', '0'),
('080103', 'Huancavelica', 'Huancavelica', 'Acoria', '090103', '0'),
('080104', 'Huancavelica', 'Huancavelica', 'Conayca', '090104', '0'),
('080105', 'Huancavelica', 'Huancavelica', 'Cuenca', '090105', '0'),
('080106', 'Huancavelica', 'Huancavelica', 'Huachocolpa', '090106', '0'),
('080108', 'Huancavelica', 'Huancavelica', 'Huayllahuara', '090107', '0'),
('080109', 'Huancavelica', 'Huancavelica', 'Izcuchaca', '090108', '0'),
('080110', 'Huancavelica', 'Huancavelica', 'Laria', '090109', '0'),
('080111', 'Huancavelica', 'Huancavelica', 'Manta', '090110', '0'),
('080112', 'Huancavelica', 'Huancavelica', 'Mariscal Caceres', '090111', '0'),
('080113', 'Huancavelica', 'Huancavelica', 'Moya', '090112', '0'),
('080114', 'Huancavelica', 'Huancavelica', 'Nuevo Occoro', '090113', '0'),
('080115', 'Huancavelica', 'Huancavelica', 'Palca', '090114', '0'),
('080116', 'Huancavelica', 'Huancavelica', 'Pilchaca', '090115', '0'),
('080117', 'Huancavelica', 'Huancavelica', 'Vilca', '090116', '0'),
('080118', 'Huancavelica', 'Huancavelica', 'Yauli', '090117', '0'),
('080119', 'Huancavelica', 'Huancavelica', 'Ascension', '090118', '0'),
('080120', 'Huancavelica', 'Huancavelica', 'Huando', '090119', '0'),
('080201', 'Huancavelica', 'Acobamba', 'Acobamba', '090201', '0'),
('080202', 'Huancavelica', 'Acobamba', 'Anta', '090203', '0'),
('080203', 'Huancavelica', 'Acobamba', 'Andabamba', '090202', '0'),
('080204', 'Huancavelica', 'Acobamba', 'Caja', '090204', '0');
INSERT INTO `ubigeo` (`ubigeo1`, `dpto`, `prov`, `distrito`, `ubigeo2`, `orden`) VALUES
('080205', 'Huancavelica', 'Acobamba', 'Marcas', '090205', '0'),
('080206', 'Huancavelica', 'Acobamba', 'Paucara', '090206', '0'),
('080207', 'Huancavelica', 'Acobamba', 'Pomacocha', '090207', '0'),
('080208', 'Huancavelica', 'Acobamba', 'Rosario', '090208', '0'),
('080301', 'Huancavelica', 'Angaraes', 'Lircay', '090301', '0'),
('080302', 'Huancavelica', 'Angaraes', 'Anchonga', '090302', '0'),
('080303', 'Huancavelica', 'Angaraes', 'Callanmarca', '090303', '0'),
('080304', 'Huancavelica', 'Angaraes', 'Congalla', '090306', '0'),
('080305', 'Huancavelica', 'Angaraes', 'Chincho', '090305', '0'),
('080306', 'Huancavelica', 'Angaraes', 'Huallay-grande', '090308', '0'),
('080307', 'Huancavelica', 'Angaraes', 'Huanca-huanca', '090307', '0'),
('080308', 'Huancavelica', 'Angaraes', 'Julcamarca', '090309', '0'),
('080309', 'Huancavelica', 'Angaraes', 'San Antonio De Antaparco', '090310', '0'),
('080310', 'Huancavelica', 'Angaraes', 'Santo Tomas De Pata', '090311', '0'),
('080311', 'Huancavelica', 'Angaraes', 'Secclla', '090312', '0'),
('080312', 'Huancavelica', 'Angaraes', 'Ccochaccasa', '090304', '0'),
('080401', 'Huancavelica', 'Castrovirreyna', 'Castrovirreyna', '090401', '0'),
('080402', 'Huancavelica', 'Castrovirreyna', 'Arma', '090402', '0'),
('080403', 'Huancavelica', 'Castrovirreyna', 'Aurahua', '090403', '0'),
('080405', 'Huancavelica', 'Castrovirreyna', 'Capillas', '090404', '0'),
('080406', 'Huancavelica', 'Castrovirreyna', 'Cocas', '090406', '0'),
('080408', 'Huancavelica', 'Castrovirreyna', 'Chupamarca', '090405', '0'),
('080409', 'Huancavelica', 'Castrovirreyna', 'Huachos', '090407', '0'),
('080410', 'Huancavelica', 'Castrovirreyna', 'Huamatambo', '090408', '0'),
('080414', 'Huancavelica', 'Castrovirreyna', 'Mollepampa', '090409', '0'),
('080422', 'Huancavelica', 'Castrovirreyna', 'San Juan', '090410', '0'),
('080427', 'Huancavelica', 'Castrovirreyna', 'Tantara', '090412', '0'),
('080428', 'Huancavelica', 'Castrovirreyna', 'Ticrapo', '090413', '0'),
('080429', 'Huancavelica', 'Castrovirreyna', 'Santa Ana', '090411', '0'),
('080501', 'Huancavelica', 'Tayacaja', 'Pampas', '090701', '0'),
('080502', 'Huancavelica', 'Tayacaja', 'Acostambo', '090702', '0'),
('080503', 'Huancavelica', 'Tayacaja', 'Acraquia', '090703', '0'),
('080504', 'Huancavelica', 'Tayacaja', 'Ahuaycha', '090704', '0'),
('080506', 'Huancavelica', 'Tayacaja', 'Colcabamba', '090705', '0'),
('080509', 'Huancavelica', 'Tayacaja', 'Daniel Hernandez', '090706', '0'),
('080511', 'Huancavelica', 'Tayacaja', 'Huachocolpa', '090707', '0'),
('080512', 'Huancavelica', 'Tayacaja', 'Huaribamba', '090709', '0'),
('080515', 'Huancavelica', 'Tayacaja', 'ñahuimpuquio', '090710', '0'),
('080517', 'Huancavelica', 'Tayacaja', 'Pazos', '090711', '0'),
('080518', 'Huancavelica', 'Tayacaja', 'Quishuar', '090713', '0'),
('080519', 'Huancavelica', 'Tayacaja', 'Salcabamba', '090714', '0'),
('080520', 'Huancavelica', 'Tayacaja', 'San Marcos De Rocchac', '090716', '0'),
('080523', 'Huancavelica', 'Tayacaja', 'Surcabamba', '090717', '0'),
('080525', 'Huancavelica', 'Tayacaja', 'Tintay Puncu', '090718', '0'),
('080526', 'Huancavelica', 'Tayacaja', 'Salcahuasi', '090715', '0'),
('080601', 'Huancavelica', 'Huaytara', 'Ayavi', '090602', '0'),
('080602', 'Huancavelica', 'Huaytara', 'Cordova', '090603', '0'),
('080603', 'Huancavelica', 'Huaytara', 'Huayacundo Arma', '090604', '0'),
('080604', 'Huancavelica', 'Huaytara', 'Huaytara', '090601', '0'),
('080605', 'Huancavelica', 'Huaytara', 'Laramarca', '090605', '0'),
('080606', 'Huancavelica', 'Huaytara', 'Ocoyo', '090606', '0'),
('080607', 'Huancavelica', 'Huaytara', 'Pilpichaca', '090607', '0'),
('080608', 'Huancavelica', 'Huaytara', 'Querco', '090608', '0'),
('080609', 'Huancavelica', 'Huaytara', 'Quito Arma', '090609', '0'),
('080610', 'Huancavelica', 'Huaytara', 'San Antonio De Cusicancha', '090610', '0'),
('080611', 'Huancavelica', 'Huaytara', 'San Francisco De Sangayaico', '090611', '0'),
('080612', 'Huancavelica', 'Huaytara', 'San Isidro', '090612', '0'),
('080613', 'Huancavelica', 'Huaytara', 'Santiago De Chocorvos', '090613', '0'),
('080614', 'Huancavelica', 'Huaytara', 'Santiago De Quirahuara', '090614', '0'),
('080615', 'Huancavelica', 'Huaytara', 'Santo Domingo De Capillas', '090615', '0'),
('080616', 'Huancavelica', 'Huaytara', 'Tambo', '090616', '0'),
('080701', 'Huancavelica', 'Churcampa', 'Churcampa', '090501', '0'),
('080702', 'Huancavelica', 'Churcampa', 'Anco', '090502', '0'),
('080703', 'Huancavelica', 'Churcampa', 'Chinchihuasi', '090503', '0'),
('080704', 'Huancavelica', 'Churcampa', 'El Carmen', '090504', '0'),
('080705', 'Huancavelica', 'Churcampa', 'La Merced', '090505', '0'),
('080706', 'Huancavelica', 'Churcampa', 'Locroja', '090506', '0'),
('080707', 'Huancavelica', 'Churcampa', 'Paucarbamba', '090507', '0'),
('080708', 'Huancavelica', 'Churcampa', 'San Miguel De Mayocc', '090508', '0'),
('080709', 'Huancavelica', 'Churcampa', 'San Pedro De Coris', '090509', '0'),
('080710', 'Huancavelica', 'Churcampa', 'Pachamarca', '090510', '0'),
('090101', 'Huanuco', 'Huanuco', 'Huanuco', '100101', '0'),
('090102', 'Huanuco', 'Huanuco', 'Chinchao', '100103', '0'),
('090103', 'Huanuco', 'Huanuco', 'Churubamba', '100104', '0'),
('090104', 'Huanuco', 'Huanuco', 'Margos', '100105', '0'),
('090105', 'Huanuco', 'Huanuco', 'Quisqui', '100106', '0'),
('090106', 'Huanuco', 'Huanuco', 'San Francisco De Cayran', '100107', '0'),
('090107', 'Huanuco', 'Huanuco', 'San Pedro De Chaulan', '100108', '0'),
('090108', 'Huanuco', 'Huanuco', 'Santa Maria Del Valle', '100109', '0'),
('090109', 'Huanuco', 'Huanuco', 'Yarumayo', '100110', '0'),
('090110', 'Huanuco', 'Huanuco', 'Amarilis', '100102', '0'),
('090111', 'Huanuco', 'Huanuco', 'Pillco Marca', '100111', '0'),
('090201', 'Huanuco', 'Ambo', 'Ambo', '100201', '1'),
('090202', 'Huanuco', 'Ambo', 'Cayna', '100202', '1'),
('090203', 'Huanuco', 'Ambo', 'Colpas', '100203', '1'),
('090204', 'Huanuco', 'Ambo', 'Conchamarca', '100204', '1'),
('090205', 'Huanuco', 'Ambo', 'Huacar', '100205', '1'),
('090206', 'Huanuco', 'Ambo', 'San Francisco', '100206', '1'),
('090207', 'Huanuco', 'Ambo', 'San Rafael', '100207', '1'),
('090208', 'Huanuco', 'Ambo', 'Tomay-kichwa', '100208', '1'),
('090301', 'Huanuco', 'Dos De Mayo', 'La Union', '100301', '1'),
('090307', 'Huanuco', 'Dos De Mayo', 'Chuquis', '100307', '1'),
('090312', 'Huanuco', 'Dos De Mayo', 'Marias', '100311', '1'),
('090314', 'Huanuco', 'Dos De Mayo', 'Pachas', '100313', '1'),
('090316', 'Huanuco', 'Dos De Mayo', 'Quivilla', '100316', '1'),
('090317', 'Huanuco', 'Dos De Mayo', 'Ripan', '100317', '1'),
('090321', 'Huanuco', 'Dos De Mayo', 'Shunqui', '100321', '1'),
('090322', 'Huanuco', 'Dos De Mayo', 'Sillapata', '100322', '1'),
('090323', 'Huanuco', 'Dos De Mayo', 'Yanas', '100323', '1'),
('090401', 'Huanuco', 'Huamalies', 'Llata', '100501', '1'),
('090402', 'Huanuco', 'Huamalies', 'Arancay', '100502', '1'),
('090403', 'Huanuco', 'Huamalies', 'Chavin De Pariarca', '100503', '1'),
('090404', 'Huanuco', 'Huamalies', 'Jacas Grande', '100504', '1'),
('090405', 'Huanuco', 'Huamalies', 'Jircan', '100505', '1'),
('090406', 'Huanuco', 'Huamalies', 'Miraflores', '100506', '1'),
('090407', 'Huanuco', 'Huamalies', 'Monzon', '100507', '1'),
('090408', 'Huanuco', 'Huamalies', 'Punchao', '100508', '1'),
('090409', 'Huanuco', 'Huamalies', 'Puños', '100509', '1'),
('090410', 'Huanuco', 'Huamalies', 'Singa', '100510', '1'),
('090411', 'Huanuco', 'Huamalies', 'Tantamayo', '100511', '1'),
('090501', 'Huanuco', 'Marañon', 'Huacrachuco', '100701', '1'),
('090502', 'Huanuco', 'Marañon', 'Cholon', '100702', '1'),
('090505', 'Huanuco', 'Marañon', 'San Buenaventura', '100703', '1'),
('090601', 'Huanuco', 'Leoncio Prado', 'Rupa-rupa', '100601', '1'),
('090602', 'Huanuco', 'Leoncio Prado', 'Daniel Alomia Robles', '100602', '1'),
('090603', 'Huanuco', 'Leoncio Prado', 'Hermilio Valdizan', '100603', '1'),
('090604', 'Huanuco', 'Leoncio Prado', 'Luyando', '100605', '1'),
('090605', 'Huanuco', 'Leoncio Prado', 'Mariano Damaso Beraun', '100606', '1'),
('090606', 'Huanuco', 'Leoncio Prado', 'Jose Crespo Y Castillo', '100604', '1'),
('090701', 'Huanuco', 'Pachitea', 'Panao', '100801', '1'),
('090702', 'Huanuco', 'Pachitea', 'Chaglla', '100802', '1'),
('090704', 'Huanuco', 'Pachitea', 'Molino', '100803', '1'),
('090706', 'Huanuco', 'Pachitea', 'Umari', '100804', '1'),
('090801', 'Huanuco', 'Puerto Inca', 'Honoria', '100903', '1'),
('090802', 'Huanuco', 'Puerto Inca', 'Puerto Inca', '100901', '1'),
('090803', 'Huanuco', 'Puerto Inca', 'Codo Del Pozuzo', '100902', '1'),
('090804', 'Huanuco', 'Puerto Inca', 'Tournavista', '100904', '1'),
('090805', 'Huanuco', 'Puerto Inca', 'Yuyapichis', '100905', '1'),
('090901', 'Huanuco', 'Huacaybamba', 'Huacaybamba', '100401', '1'),
('090902', 'Huanuco', 'Huacaybamba', 'Pinra', '100404', '1'),
('090903', 'Huanuco', 'Huacaybamba', 'Canchabamba', '100402', '1'),
('090904', 'Huanuco', 'Huacaybamba', 'Cochabamba', '100403', '1'),
('091001', 'Huanuco', 'Lauricocha', 'Jesus', '101001', '1'),
('091002', 'Huanuco', 'Lauricocha', 'Baños', '101002', '1'),
('091003', 'Huanuco', 'Lauricocha', 'San Francisco De Asis', '101006', '1'),
('091004', 'Huanuco', 'Lauricocha', 'Queropalca', '101004', '1'),
('091005', 'Huanuco', 'Lauricocha', 'San Miguel De Cauri', '101007', '1'),
('091006', 'Huanuco', 'Lauricocha', 'Rondos', '101005', '1'),
('091007', 'Huanuco', 'Lauricocha', 'Jivia', '101003', '1'),
('091101', 'Huanuco', 'Yarowilca', 'Chavinillo', '101101', '1'),
('091102', 'Huanuco', 'Yarowilca', 'Aparicio Pomares', '101104', '1'),
('091103', 'Huanuco', 'Yarowilca', 'Cahuac', '101102', '1'),
('091104', 'Huanuco', 'Yarowilca', 'Chacabamba', '101103', '1'),
('091105', 'Huanuco', 'Yarowilca', 'Jacas Chico', '101105', '1'),
('091106', 'Huanuco', 'Yarowilca', 'Obas', '101106', '1'),
('091107', 'Huanuco', 'Yarowilca', 'Pampamarca', '101107', '1'),
('091108', 'Huanuco', 'Yarowilca', 'Choras', '101108', '1'),
('100101', 'Ica', 'Ica', 'Ica', '110101', '0'),
('100102', 'Ica', 'Ica', 'La Tinguiña', '110102', '0'),
('100103', 'Ica', 'Ica', 'Los Aquijes', '110103', '0'),
('100104', 'Ica', 'Ica', 'Parcona', '110106', '0'),
('100105', 'Ica', 'Ica', 'Pueblo Nuevo', '110107', '0'),
('100106', 'Ica', 'Ica', 'Salas', '110108', '0'),
('100107', 'Ica', 'Ica', 'San Jose De Los Molinos', '110109', '0'),
('100108', 'Ica', 'Ica', 'San Juan Bautista', '110110', '0'),
('100109', 'Ica', 'Ica', 'Santiago', '110111', '0'),
('100110', 'Ica', 'Ica', 'Subtanjalla', '110112', '0'),
('100111', 'Ica', 'Ica', 'Yauca Del Rosario', '110114', '0'),
('100112', 'Ica', 'Ica', 'Tate', '110113', '0'),
('100113', 'Ica', 'Ica', 'Pachacutec', '110105', '0'),
('100114', 'Ica', 'Ica', 'Ocucaje', '110104', '0'),
('100201', 'Ica', 'Chincha', 'Chincha Alta', '110201', '0'),
('100202', 'Ica', 'Chincha', 'Chavin', '110203', '0'),
('100203', 'Ica', 'Chincha', 'Chincha Baja', '110204', '0'),
('100204', 'Ica', 'Chincha', 'El Carmen', '110205', '0'),
('100205', 'Ica', 'Chincha', 'Grocio Prado', '110206', '0'),
('100206', 'Ica', 'Chincha', 'San Pedro De Huacarpana', '110209', '0'),
('100207', 'Ica', 'Chincha', 'Sunampe', '110210', '0'),
('100208', 'Ica', 'Chincha', 'Tambo De Mora', '110211', '0'),
('100209', 'Ica', 'Chincha', 'Alto Laran', '110202', '0'),
('100210', 'Ica', 'Chincha', 'Pueblo Nuevo', '110207', '0'),
('100211', 'Ica', 'Chincha', 'San Juan De Yanac', '110208', '0'),
('100301', 'Ica', 'Nazca', 'Nazca', '110301', '0'),
('100302', 'Ica', 'Nazca', 'Changuillo', '110302', '0'),
('100303', 'Ica', 'Nazca', 'El Ingenio', '110303', '0'),
('100304', 'Ica', 'Nazca', 'Marcona', '110304', '0'),
('100305', 'Ica', 'Nazca', 'Vista Alegre', '110305', '0'),
('100401', 'Ica', 'Pisco', 'Pisco', '110501', '0'),
('100402', 'Ica', 'Pisco', 'Huancano', '110502', '0'),
('100403', 'Ica', 'Pisco', 'Humay', '110503', '0'),
('100404', 'Ica', 'Pisco', 'Independencia', '110504', '0'),
('100405', 'Ica', 'Pisco', 'Paracas', '110505', '0'),
('100406', 'Ica', 'Pisco', 'San Andres', '110506', '0'),
('100407', 'Ica', 'Pisco', 'San Clemente', '110507', '0'),
('100408', 'Ica', 'Pisco', 'Tupac Amaru Inca', '110508', '0'),
('100501', 'Ica', 'Palpa', 'Palpa', '110401', '0'),
('100502', 'Ica', 'Palpa', 'Llipata', '110402', '0'),
('100503', 'Ica', 'Palpa', 'Rio Grande', '110403', '0'),
('100504', 'Ica', 'Palpa', 'Santa Cruz', '110404', '0'),
('100505', 'Ica', 'Palpa', 'Tibillo', '110405', '0'),
('110101', 'Junin', 'Huancayo', 'Huancayo', '120101', '0'),
('110103', 'Junin', 'Huancayo', 'Carhuacallanga', '120104', '0'),
('110104', 'Junin', 'Huancayo', 'Colca', '120112', '0'),
('110105', 'Junin', 'Huancayo', 'Cullhuas', '120113', '0'),
('110106', 'Junin', 'Huancayo', 'Chacapampa', '120105', '0'),
('110107', 'Junin', 'Huancayo', 'Chicche', '120106', '0'),
('110108', 'Junin', 'Huancayo', 'Chilca', '120107', '0'),
('110109', 'Junin', 'Huancayo', 'Chongos Alto', '120108', '0'),
('110112', 'Junin', 'Huancayo', 'Chupuro', '120111', '0'),
('110113', 'Junin', 'Huancayo', 'El Tambo', '120114', '0'),
('110114', 'Junin', 'Huancayo', 'Huacrapuquio', '120116', '0'),
('110116', 'Junin', 'Huancayo', 'Hualhuas', '120117', '0'),
('110118', 'Junin', 'Huancayo', 'Huancan', '120119', '0'),
('110119', 'Junin', 'Huancayo', 'Huasicancha', '120120', '0'),
('110120', 'Junin', 'Huancayo', 'Huayucachi', '120121', '0'),
('110121', 'Junin', 'Huancayo', 'Ingenio', '120122', '0'),
('110122', 'Junin', 'Huancayo', 'Pariahuanca', '120124', '0'),
('110123', 'Junin', 'Huancayo', 'Pilcomayo', '120125', '0'),
('110124', 'Junin', 'Huancayo', 'Pucara', '120126', '0'),
('110125', 'Junin', 'Huancayo', 'Quichuay', '120127', '0'),
('110126', 'Junin', 'Huancayo', 'Quilcas', '120128', '0'),
('110127', 'Junin', 'Huancayo', 'San Agustin', '120129', '0'),
('110128', 'Junin', 'Huancayo', 'San Jeronimo De Tunan', '120130', '0'),
('110131', 'Junin', 'Huancayo', 'Santo Domingo De Acobamba', '120135', '0'),
('110132', 'Junin', 'Huancayo', 'Saño', '120132', '0'),
('110133', 'Junin', 'Huancayo', 'Sapallanga', '120133', '0'),
('110134', 'Junin', 'Huancayo', 'Sicaya', '120134', '0'),
('110136', 'Junin', 'Huancayo', 'Viques', '120136', '0'),
('110201', 'Junin', 'Concepcion', 'Concepcion', '120201', '1'),
('110202', 'Junin', 'Concepcion', 'Aco', '120202', '1'),
('110203', 'Junin', 'Concepcion', 'Andamarca', '120203', '1'),
('110204', 'Junin', 'Concepcion', 'Comas', '120206', '1'),
('110205', 'Junin', 'Concepcion', 'Cochas', '120205', '1'),
('110206', 'Junin', 'Concepcion', 'Chambara', '120204', '1'),
('110207', 'Junin', 'Concepcion', 'Heroinas Toledo', '120207', '1'),
('110208', 'Junin', 'Concepcion', 'Manzanares', '120208', '1'),
('110209', 'Junin', 'Concepcion', 'Mariscal Castilla', '120209', '1'),
('110210', 'Junin', 'Concepcion', 'Matahuasi', '120210', '1'),
('110211', 'Junin', 'Concepcion', 'Mito', '120211', '1'),
('110212', 'Junin', 'Concepcion', 'Nueve De Julio', '120212', '1'),
('110213', 'Junin', 'Concepcion', 'Orcotuna', '120213', '1'),
('110214', 'Junin', 'Concepcion', 'Santa Rosa De Ocopa', '120215', '1'),
('110215', 'Junin', 'Concepcion', 'San Jose De Quero', '120214', '1'),
('110301', 'Junin', 'Jauja', 'Jauja', '120401', '1'),
('110302', 'Junin', 'Jauja', 'Acolla', '120402', '1'),
('110303', 'Junin', 'Jauja', 'Apata', '120403', '1'),
('110304', 'Junin', 'Jauja', 'Ataura', '120404', '1'),
('110305', 'Junin', 'Jauja', 'Canchayllo', '120405', '1'),
('110306', 'Junin', 'Jauja', 'El Mantaro', '120407', '1'),
('110307', 'Junin', 'Jauja', 'Huamali', '120408', '1'),
('110308', 'Junin', 'Jauja', 'Huaripampa', '120409', '1'),
('110309', 'Junin', 'Jauja', 'Huertas', '120410', '1'),
('110310', 'Junin', 'Jauja', 'Janjaillo', '120411', '1'),
('110311', 'Junin', 'Jauja', 'Julcan', '120412', '1'),
('110312', 'Junin', 'Jauja', 'Leonor Ordoñez', '120413', '1'),
('110313', 'Junin', 'Jauja', 'Llocllapampa', '120414', '1'),
('110314', 'Junin', 'Jauja', 'Marco', '120415', '1'),
('110315', 'Junin', 'Jauja', 'Masma', '120416', '1'),
('110316', 'Junin', 'Jauja', 'Molinos', '120418', '1'),
('110317', 'Junin', 'Jauja', 'Monobamba', '120419', '1'),
('110318', 'Junin', 'Jauja', 'Muqui', '120420', '1'),
('110319', 'Junin', 'Jauja', 'Muquiyauyo', '120421', '1'),
('110320', 'Junin', 'Jauja', 'Paca', '120422', '1'),
('110321', 'Junin', 'Jauja', 'Paccha', '120423', '1'),
('110322', 'Junin', 'Jauja', 'Pancan', '120424', '1'),
('110323', 'Junin', 'Jauja', 'Parco', '120425', '1'),
('110324', 'Junin', 'Jauja', 'Pomacancha', '120426', '1'),
('110325', 'Junin', 'Jauja', 'Ricran', '120427', '1'),
('110326', 'Junin', 'Jauja', 'San Lorenzo', '120428', '1'),
('110327', 'Junin', 'Jauja', 'San Pedro De Chunan', '120429', '1'),
('110328', 'Junin', 'Jauja', 'Sincos', '120431', '1'),
('110329', 'Junin', 'Jauja', 'Tunan Marca', '120432', '1'),
('110330', 'Junin', 'Jauja', 'Yauli', '120433', '1'),
('110331', 'Junin', 'Jauja', 'Curicaca', '120406', '1'),
('110332', 'Junin', 'Jauja', 'Masma Chicche', '120417', '1'),
('110333', 'Junin', 'Jauja', 'Sausa', '120430', '1'),
('110334', 'Junin', 'Jauja', 'Yauyos', '120434', '1'),
('110401', 'Junin', 'Junin', 'Junin', '120501', '1'),
('110402', 'Junin', 'Junin', 'Carhuamayo', '120502', '1'),
('110403', 'Junin', 'Junin', 'Ondores', '120503', '1'),
('110404', 'Junin', 'Junin', 'Ulcumayo', '120504', '1'),
('110501', 'Junin', 'Tarma', 'Tarma', '120701', '1'),
('110502', 'Junin', 'Tarma', 'Acobamba', '120702', '1'),
('110503', 'Junin', 'Tarma', 'Huaricolca', '120703', '1'),
('110504', 'Junin', 'Tarma', 'Huasahuasi', '120704', '1'),
('110505', 'Junin', 'Tarma', 'La Union', '120705', '1'),
('110506', 'Junin', 'Tarma', 'Palca', '120706', '1'),
('110507', 'Junin', 'Tarma', 'Palcamayo', '120707', '1'),
('110508', 'Junin', 'Tarma', 'San Pedro De Cajas', '120708', '1'),
('110509', 'Junin', 'Tarma', 'Tapo', '120709', '1'),
('110601', 'Junin', 'Yauli', 'La Oroya', '120801', '1'),
('110602', 'Junin', 'Yauli', 'Chacapalpa', '120802', '1'),
('110603', 'Junin', 'Yauli', 'Huay Huay', '120803', '1'),
('110604', 'Junin', 'Yauli', 'Marcapomacocha', '120804', '1'),
('110605', 'Junin', 'Yauli', 'Morococha', '120805', '1'),
('110606', 'Junin', 'Yauli', 'Paccha', '120806', '1'),
('110607', 'Junin', 'Yauli', 'Santa Barbara De Carhuacayan', '120807', '1'),
('110608', 'Junin', 'Yauli', 'Suitucancha', '120809', '1'),
('110609', 'Junin', 'Yauli', 'Yauli', '120810', '1'),
('110610', 'Junin', 'Yauli', 'Santa Rosa De Sacco', '120808', '1'),
('110701', 'Junin', 'Satipo', 'Satipo', '120601', '1'),
('110702', 'Junin', 'Satipo', 'Coviriali', '120602', '1'),
('110703', 'Junin', 'Satipo', 'Llaylla', '120603', '1'),
('110704', 'Junin', 'Satipo', 'Mazamari', '120604', '1'),
('110705', 'Junin', 'Satipo', 'Pampa Hermosa', '120605', '1'),
('110706', 'Junin', 'Satipo', 'Pangoa', '120606', '1'),
('110707', 'Junin', 'Satipo', 'Rio Negro', '120607', '1'),
('110708', 'Junin', 'Satipo', 'Rio Tambo', '120608', '1'),
('110801', 'Junin', 'Chanchamayo', 'Chanchamayo', '120301', '1'),
('110802', 'Junin', 'Chanchamayo', 'San Ramon', '120305', '1'),
('110803', 'Junin', 'Chanchamayo', 'Vitoc', '120306', '1'),
('110804', 'Junin', 'Chanchamayo', 'San Luis De Shuaro', '120304', '1'),
('110805', 'Junin', 'Chanchamayo', 'Pichanaqui', '120303', '1'),
('110806', 'Junin', 'Chanchamayo', 'Perene', '120302', '1'),
('110901', 'Junin', 'Chupaca', 'Chupaca', '120901', '1'),
('110902', 'Junin', 'Chupaca', 'Ahuac', '120902', '1'),
('110903', 'Junin', 'Chupaca', 'Chongos Bajo', '120903', '1'),
('110904', 'Junin', 'Chupaca', 'Huachac', '120904', '1'),
('110905', 'Junin', 'Chupaca', 'Huamancaca Chico', '120905', '1'),
('110906', 'Junin', 'Chupaca', 'San Juan De Yscos', '120906', '1'),
('110907', 'Junin', 'Chupaca', 'San Juan De Jarpa', '120907', '1'),
('110908', 'Junin', 'Chupaca', 'Tres De Diciembre', '120908', '1'),
('110909', 'Junin', 'Chupaca', 'Yanacancha', '120909', '1'),
('120101', 'La Libertad', 'Trujillo', 'Trujillo', '130101', '0'),
('120102', 'La Libertad', 'Trujillo', 'Huanchaco', '130104', '0'),
('120103', 'La Libertad', 'Trujillo', 'Laredo', '130106', '0'),
('120104', 'La Libertad', 'Trujillo', 'Moche', '130107', '0'),
('120105', 'La Libertad', 'Trujillo', 'Salaverry', '130109', '0'),
('120106', 'La Libertad', 'Trujillo', 'Simbal', '130110', '0'),
('120107', 'La Libertad', 'Trujillo', 'Victor Larco Herrera', '130111', '0'),
('120109', 'La Libertad', 'Trujillo', 'Poroto', '130108', '0'),
('120110', 'La Libertad', 'Trujillo', 'El Porvenir', '130102', '0'),
('120111', 'La Libertad', 'Trujillo', 'La Esperanza', '130105', '0'),
('120112', 'La Libertad', 'Trujillo', 'Florencia De Mora', '130103', '0'),
('120201', 'La Libertad', 'Bolivar', 'Bolivar', '130301', '1'),
('120202', 'La Libertad', 'Bolivar', 'Bambamarca', '130302', '1'),
('120203', 'La Libertad', 'Bolivar', 'Condormarca', '130303', '1'),
('120204', 'La Libertad', 'Bolivar', 'Longotea', '130304', '1'),
('120205', 'La Libertad', 'Bolivar', 'Ucuncha', '130306', '1'),
('120206', 'La Libertad', 'Bolivar', 'Uchumarca', '130305', '1'),
('120301', 'La Libertad', 'Sanchez Carrion', 'Huamachuco', '130901', '1'),
('120302', 'La Libertad', 'Sanchez Carrion', 'Cochorco', '130903', '1'),
('120303', 'La Libertad', 'Sanchez Carrion', 'Curgos', '130904', '1'),
('120304', 'La Libertad', 'Sanchez Carrion', 'Chugay', '130902', '1'),
('120305', 'La Libertad', 'Sanchez Carrion', 'Marcabal', '130905', '1'),
('120306', 'La Libertad', 'Sanchez Carrion', 'Sanagoran', '130906', '1'),
('120307', 'La Libertad', 'Sanchez Carrion', 'Sarin', '130907', '1'),
('120308', 'La Libertad', 'Sanchez Carrion', 'Sartibamba', '130908', '1'),
('120401', 'La Libertad', 'Otuzco', 'Otuzco', '130601', '1'),
('120402', 'La Libertad', 'Otuzco', 'Agallpampa', '130602', '1'),
('120403', 'La Libertad', 'Otuzco', 'Charat', '130604', '1'),
('120404', 'La Libertad', 'Otuzco', 'Huaranchal', '130605', '1'),
('120405', 'La Libertad', 'Otuzco', 'La Cuesta', '130606', '1'),
('120408', 'La Libertad', 'Otuzco', 'Paranday', '130610', '1'),
('120409', 'La Libertad', 'Otuzco', 'Salpo', '130611', '1'),
('120410', 'La Libertad', 'Otuzco', 'Sinsicap', '130613', '1'),
('120411', 'La Libertad', 'Otuzco', 'Usquil', '130614', '1'),
('120413', 'La Libertad', 'Otuzco', 'Mache', '130608', '1'),
('120501', 'La Libertad', 'Pacasmayo', 'San Pedro De Lloc', '130701', '1'),
('120503', 'La Libertad', 'Pacasmayo', 'Guadalupe', '130702', '1'),
('120504', 'La Libertad', 'Pacasmayo', 'Jequetepeque', '130703', '1'),
('120506', 'La Libertad', 'Pacasmayo', 'Pacasmayo', '130704', '1'),
('120508', 'La Libertad', 'Pacasmayo', 'San Jose', '130705', '1'),
('120601', 'La Libertad', 'Pataz', 'Tayabamba', '130801', '1'),
('120602', 'La Libertad', 'Pataz', 'Buldibuyo', '130802', '1'),
('120603', 'La Libertad', 'Pataz', 'Chillia', '130803', '1'),
('120604', 'La Libertad', 'Pataz', 'Huaylillas', '130805', '1'),
('120605', 'La Libertad', 'Pataz', 'Huancaspata', '130804', '1'),
('120606', 'La Libertad', 'Pataz', 'Huayo', '130806', '1'),
('120607', 'La Libertad', 'Pataz', 'Ongon', '130807', '1'),
('120608', 'La Libertad', 'Pataz', 'Parcoy', '130808', '1'),
('120609', 'La Libertad', 'Pataz', 'Pataz', '130809', '1'),
('120610', 'La Libertad', 'Pataz', 'Pias', '130810', '1'),
('120611', 'La Libertad', 'Pataz', 'Taurija', '130812', '1'),
('120612', 'La Libertad', 'Pataz', 'Urpay', '130813', '1'),
('120613', 'La Libertad', 'Pataz', 'Santiago De Challas', '130811', '1'),
('120701', 'La Libertad', 'Santiago De Chuco', 'Santiago De Chuco', '131001', '1'),
('120702', 'La Libertad', 'Santiago De Chuco', 'Cachicadan', '131003', '1'),
('120703', 'La Libertad', 'Santiago De Chuco', 'Mollebamba', '131004', '1'),
('120704', 'La Libertad', 'Santiago De Chuco', 'Mollepata', '131005', '1'),
('120705', 'La Libertad', 'Santiago De Chuco', 'Quiruvilca', '131006', '1'),
('120706', 'La Libertad', 'Santiago De Chuco', 'Santa Cruz De Chuca', '131007', '1'),
('120707', 'La Libertad', 'Santiago De Chuco', 'Sitabamba', '131008', '1'),
('120708', 'La Libertad', 'Santiago De Chuco', 'Angasmarca', '131002', '1'),
('120801', 'La Libertad', 'Ascope', 'Ascope', '130201', '1'),
('120802', 'La Libertad', 'Ascope', 'Chicama', '130202', '1'),
('120803', 'La Libertad', 'Ascope', 'Chocope', '130203', '1'),
('120804', 'La Libertad', 'Ascope', 'Santiago De Cao', '130207', '1'),
('120805', 'La Libertad', 'Ascope', 'Magdalena De Cao', '130204', '1'),
('120806', 'La Libertad', 'Ascope', 'Paijan', '130205', '1'),
('120807', 'La Libertad', 'Ascope', 'Razuri', '130206', '1'),
('120808', 'La Libertad', 'Ascope', 'Casa Grande', '130208', '1'),
('120901', 'La Libertad', 'Chepen', 'Chepen', '130401', '1'),
('120902', 'La Libertad', 'Chepen', 'Pacanga', '130402', '1'),
('120903', 'La Libertad', 'Chepen', 'Pueblo Nuevo', '130403', '1'),
('121001', 'La Libertad', 'Julcan', 'Julcan', '130501', '1'),
('121002', 'La Libertad', 'Julcan', 'Carabamba', '130503', '1'),
('121003', 'La Libertad', 'Julcan', 'Calamarca', '130502', '1'),
('121004', 'La Libertad', 'Julcan', 'Huaso', '130504', '1'),
('121101', 'La Libertad', 'Gran Chimu', 'Cascas', '131101', '1'),
('121102', 'La Libertad', 'Gran Chimu', 'Lucma', '131102', '1'),
('121103', 'La Libertad', 'Gran Chimu', 'Marmot', '131103', '1'),
('121104', 'La Libertad', 'Gran Chimu', 'Sayapullo', '131104', '1'),
('121201', 'La Libertad', 'Viru', 'Viru', '131201', '1'),
('121202', 'La Libertad', 'Viru', 'Chao', '131202', '1'),
('121203', 'La Libertad', 'Viru', 'Guadalupito', '131203', '1'),
('130101', 'Lambayeque', 'Chiclayo', 'Chiclayo', '140101', '0'),
('130102', 'Lambayeque', 'Chiclayo', 'Chongoyape', '140102', '0'),
('130103', 'Lambayeque', 'Chiclayo', 'Eten', '140103', '0'),
('130104', 'Lambayeque', 'Chiclayo', 'Eten Puerto', '140104', '0'),
('130105', 'Lambayeque', 'Chiclayo', 'Lagunas', '140107', '0'),
('130106', 'Lambayeque', 'Chiclayo', 'Monsefu', '140108', '0'),
('130107', 'Lambayeque', 'Chiclayo', 'Nueva Arica', '140109', '0'),
('130108', 'Lambayeque', 'Chiclayo', 'Oyotun', '140110', '0'),
('130109', 'Lambayeque', 'Chiclayo', 'Picsi', '140111', '0'),
('130110', 'Lambayeque', 'Chiclayo', 'Pimentel', '140112', '0'),
('130111', 'Lambayeque', 'Chiclayo', 'Reque', '140113', '0'),
('130112', 'Lambayeque', 'Chiclayo', 'Jose Leonardo Ortiz', '140105', '0'),
('130113', 'Lambayeque', 'Chiclayo', 'Santa Rosa', '140114', '0'),
('130114', 'Lambayeque', 'Chiclayo', 'Saña', '140115', '0'),
('130115', 'Lambayeque', 'Chiclayo', 'La Victoria', '140106', '0'),
('130116', 'Lambayeque', 'Chiclayo', 'Cayalti', '140116', '0'),
('130117', 'Lambayeque', 'Chiclayo', 'Patapo', '140117', '0'),
('130118', 'Lambayeque', 'Chiclayo', 'Pomalca', '140118', '0'),
('130119', 'Lambayeque', 'Chiclayo', 'Pucala', '140119', '0'),
('130120', 'Lambayeque', 'Chiclayo', 'Tuman', '140120', '0'),
('130201', 'Lambayeque', 'Ferreñafe', 'Ferreñafe', '140201', '1'),
('130202', 'Lambayeque', 'Ferreñafe', 'Incahuasi', '140203', '1'),
('130203', 'Lambayeque', 'Ferreñafe', 'Cañaris', '140202', '1'),
('130204', 'Lambayeque', 'Ferreñafe', 'Pitipo', '140205', '1'),
('130205', 'Lambayeque', 'Ferreñafe', 'Pueblo Nuevo', '140206', '1'),
('130206', 'Lambayeque', 'Ferreñafe', 'Manuel Antonio Mesones Muro', '140204', '1'),
('130301', 'Lambayeque', 'Lambayeque', 'Lambayeque', '140301', '1'),
('130302', 'Lambayeque', 'Lambayeque', 'Chochope', '140302', '1'),
('130303', 'Lambayeque', 'Lambayeque', 'Illimo', '140303', '1'),
('130304', 'Lambayeque', 'Lambayeque', 'Jayanca', '140304', '1'),
('130305', 'Lambayeque', 'Lambayeque', 'Mochumi', '140305', '1'),
('130306', 'Lambayeque', 'Lambayeque', 'Morrope', '140306', '1'),
('130307', 'Lambayeque', 'Lambayeque', 'Motupe', '140307', '1'),
('130308', 'Lambayeque', 'Lambayeque', 'Olmos', '140308', '1'),
('130309', 'Lambayeque', 'Lambayeque', 'Pacora', '140309', '1'),
('130310', 'Lambayeque', 'Lambayeque', 'Salas', '140310', '1'),
('130311', 'Lambayeque', 'Lambayeque', 'San Jose', '140311', '1'),
('130312', 'Lambayeque', 'Lambayeque', 'Tucume', '140312', '1'),
('140101', 'Lima', 'Lima', 'Lima', '150101', '0'),
('140102', 'Lima', 'Lima', 'Ancon', '150102', '0'),
('140103', 'Lima', 'Lima', 'Ate', '150103', '0'),
('140104', 'Lima', 'Lima', 'Breña', '150105', '0'),
('140105', 'Lima', 'Lima', 'Carabayllo', '150106', '0'),
('140106', 'Lima', 'Lima', 'Comas', '150110', '0'),
('140107', 'Lima', 'Lima', 'Chaclacayo', '150107', '0'),
('140108', 'Lima', 'Lima', 'Chorrillos', '150108', '0'),
('140109', 'Lima', 'Lima', 'La Victoria', '150115', '0'),
('140110', 'Lima', 'Lima', 'La Molina', '150114', '0'),
('140111', 'Lima', 'Lima', 'Lince', '150116', '0'),
('140112', 'Lima', 'Lima', 'Lurigancho', '150118', '0'),
('140113', 'Lima', 'Lima', 'Lurin', '150119', '0'),
('140114', 'Lima', 'Lima', 'Magdalena Del Mar', '150120', '0'),
('140115', 'Lima', 'Lima', 'Miraflores', '150122', '0'),
('140116', 'Lima', 'Lima', 'Pachacamac', '150123', '0'),
('140117', 'Lima', 'Lima', 'Pueblo Libre', '150121', '0'),
('140118', 'Lima', 'Lima', 'Pucusana', '150124', '0'),
('140119', 'Lima', 'Lima', 'Puente Piedra', '150125', '0'),
('140120', 'Lima', 'Lima', 'Punta Hermosa', '150126', '0'),
('140121', 'Lima', 'Lima', 'Punta Negra', '150127', '0'),
('140122', 'Lima', 'Lima', 'Rimac', '150128', '0'),
('140123', 'Lima', 'Lima', 'San Bartolo', '150129', '0'),
('140124', 'Lima', 'Lima', 'San Isidro', '150131', '0'),
('140125', 'Lima', 'Lima', 'Barranco', '150104', '0'),
('140126', 'Lima', 'Lima', 'San Martin De Porres', '150135', '0'),
('140127', 'Lima', 'Lima', 'San Miguel', '150136', '0'),
('140128', 'Lima', 'Lima', 'Santa Maria Del Mar', '150138', '0'),
('140129', 'Lima', 'Lima', 'Santa Rosa', '150139', '0'),
('140130', 'Lima', 'Lima', 'Santiago De Surco', '150140', '0'),
('140131', 'Lima', 'Lima', 'Surquillo', '150141', '0'),
('140132', 'Lima', 'Lima', 'Villa Maria Del Triunfo', '150143', '0'),
('140133', 'Lima', 'Lima', 'Jesus Maria', '150113', '0'),
('140134', 'Lima', 'Lima', 'Independencia', '150112', '0'),
('140135', 'Lima', 'Lima', 'El Agustino', '150111', '0'),
('140136', 'Lima', 'Lima', 'San Juan De Miraflores', '150133', '0'),
('140137', 'Lima', 'Lima', 'San Juan De Lurigancho', '150132', '0'),
('140138', 'Lima', 'Lima', 'San Luis', '150134', '0'),
('140139', 'Lima', 'Lima', 'Cieneguilla', '150109', '0'),
('140140', 'Lima', 'Lima', 'San Borja', '150130', '0'),
('140141', 'Lima', 'Lima', 'Villa El Salvador', '150142', '0'),
('140142', 'Lima', 'Lima', 'Los Olivos', '150117', '0'),
('140143', 'Lima', 'Lima', 'Santa Anita', '150137', '0'),
('140201', 'Lima', 'Cajatambo', 'Cajatambo', '150301', '0'),
('140205', 'Lima', 'Cajatambo', 'Copa', '150302', '0'),
('140206', 'Lima', 'Cajatambo', 'Gorgor', '150303', '0'),
('140207', 'Lima', 'Cajatambo', 'Huancapon', '150304', '0'),
('140208', 'Lima', 'Cajatambo', 'Manas', '150305', '0'),
('140301', 'Lima', 'Canta', 'Canta', '150401', '0'),
('140302', 'Lima', 'Canta', 'Arahuay', '150402', '0'),
('140303', 'Lima', 'Canta', 'Huamantanga', '150403', '0'),
('140304', 'Lima', 'Canta', 'Huaros', '150404', '0'),
('140305', 'Lima', 'Canta', 'Lachaqui', '150405', '0'),
('140306', 'Lima', 'Canta', 'San Buenaventura', '150406', '0'),
('140307', 'Lima', 'Canta', 'Santa Rosa De Quives', '150407', '0'),
('140401', 'Lima', 'Cañete', 'San Vicente De Cañete', '150501', '0'),
('140402', 'Lima', 'Cañete', 'Calango', '150503', '0'),
('140403', 'Lima', 'Cañete', 'Cerro Azul', '150504', '0'),
('140404', 'Lima', 'Cañete', 'Coayllo', '150506', '0'),
('140405', 'Lima', 'Cañete', 'Chilca', '150505', '0'),
('140406', 'Lima', 'Cañete', 'Imperial', '150507', '0'),
('140407', 'Lima', 'Cañete', 'Lunahuana', '150508', '0'),
('140408', 'Lima', 'Cañete', 'Mala', '150509', '0'),
('140409', 'Lima', 'Cañete', 'Nuevo Imperial', '150510', '0'),
('140410', 'Lima', 'Cañete', 'Pacaran', '150511', '0'),
('140411', 'Lima', 'Cañete', 'Quilmana', '150512', '0'),
('140412', 'Lima', 'Cañete', 'San Antonio', '150513', '0'),
('140413', 'Lima', 'Cañete', 'San Luis', '150514', '0'),
('140414', 'Lima', 'Cañete', 'Santa Cruz De Flores', '150515', '0'),
('140415', 'Lima', 'Cañete', 'Zuñiga', '150516', '0'),
('140416', 'Lima', 'Cañete', 'Asia', '150502', '0'),
('140501', 'Lima', 'Huaura', 'Huacho', '150801', '0'),
('140502', 'Lima', 'Huaura', 'Ambar', '150802', '0'),
('140504', 'Lima', 'Huaura', 'Caleta De Carquin', '150803', '0'),
('140505', 'Lima', 'Huaura', 'Checras', '150804', '0'),
('140506', 'Lima', 'Huaura', 'Hualmay', '150805', '0'),
('140507', 'Lima', 'Huaura', 'Huaura', '150806', '0'),
('140508', 'Lima', 'Huaura', 'Leoncio Prado', '150807', '0'),
('140509', 'Lima', 'Huaura', 'Paccho', '150808', '0'),
('140511', 'Lima', 'Huaura', 'Santa Leonor', '150809', '0'),
('140512', 'Lima', 'Huaura', 'Santa Maria', '150810', '0'),
('140513', 'Lima', 'Huaura', 'Sayan', '150811', '0'),
('140516', 'Lima', 'Huaura', 'Vegueta', '150812', '0'),
('140601', 'Lima', 'Huarochiri', 'Matucana', '150701', '0'),
('140602', 'Lima', 'Huarochiri', 'Antioquia', '150702', '0'),
('140603', 'Lima', 'Huarochiri', 'Callahuanca', '150703', '0'),
('140604', 'Lima', 'Huarochiri', 'Carampoma', '150704', '0'),
('140605', 'Lima', 'Huarochiri', 'San Pedro De Casta', '150724', '0'),
('140606', 'Lima', 'Huarochiri', 'Cuenca', '150706', '0'),
('140607', 'Lima', 'Huarochiri', 'Chicla', '150705', '0'),
('140608', 'Lima', 'Huarochiri', 'Huanza', '150708', '0'),
('140609', 'Lima', 'Huarochiri', 'Huarochiri', '150709', '0'),
('140610', 'Lima', 'Huarochiri', 'Lahuaytambo', '150710', '0'),
('140611', 'Lima', 'Huarochiri', 'Langa', '150711', '0'),
('140612', 'Lima', 'Huarochiri', 'Mariatana', '150713', '0'),
('140613', 'Lima', 'Huarochiri', 'Ricardo Palma', '150714', '0'),
('140614', 'Lima', 'Huarochiri', 'San Andres De Tupicocha', '150715', '0'),
('140615', 'Lima', 'Huarochiri', 'San Antonio', '150716', '0'),
('140616', 'Lima', 'Huarochiri', 'San Bartolome', '150717', '0'),
('140617', 'Lima', 'Huarochiri', 'San Damian', '150718', '0'),
('140618', 'Lima', 'Huarochiri', 'Sangallaya', '150726', '0'),
('140619', 'Lima', 'Huarochiri', 'San Juan De Tantaranche', '150720', '0'),
('140620', 'Lima', 'Huarochiri', 'San Lorenzo De Quinti', '150721', '0'),
('140621', 'Lima', 'Huarochiri', 'San Mateo', '150722', '0'),
('140622', 'Lima', 'Huarochiri', 'San Mateo De Otao', '150723', '0'),
('140623', 'Lima', 'Huarochiri', 'San Pedro De Huancayre', '150725', '0'),
('140624', 'Lima', 'Huarochiri', 'Santa Cruz De Cocachacra', '150727', '0'),
('140625', 'Lima', 'Huarochiri', 'Santa Eulalia', '150728', '0'),
('140626', 'Lima', 'Huarochiri', 'Santiago De Anchucaya', '150729', '0'),
('140627', 'Lima', 'Huarochiri', 'Santiago De Tuna', '150730', '0'),
('140628', 'Lima', 'Huarochiri', 'Santo Domingo De Los Olleros', '150731', '0'),
('140629', 'Lima', 'Huarochiri', 'Surco', '150732', '0'),
('140630', 'Lima', 'Huarochiri', 'Huachupampa', '150707', '0'),
('140631', 'Lima', 'Huarochiri', 'Laraos', '150712', '0'),
('140632', 'Lima', 'Huarochiri', 'San Juan De Iris', '150719', '0'),
('140701', 'Lima', 'Yauyos', 'Yauyos', '151001', '0'),
('140702', 'Lima', 'Yauyos', 'Alis', '151002', '0'),
('140703', 'Lima', 'Yauyos', 'Ayauca', '151003', '0'),
('140704', 'Lima', 'Yauyos', 'Ayaviri', '151004', '0'),
('140705', 'Lima', 'Yauyos', 'Azangaro', '151005', '0'),
('140706', 'Lima', 'Yauyos', 'Cacra', '151006', '0'),
('140707', 'Lima', 'Yauyos', 'Carania', '151007', '0'),
('140708', 'Lima', 'Yauyos', 'Cochas', '151010', '0'),
('140709', 'Lima', 'Yauyos', 'Colonia', '151011', '0'),
('140710', 'Lima', 'Yauyos', 'Chocos', '151009', '0'),
('140711', 'Lima', 'Yauyos', 'Huampara', '151013', '0'),
('140712', 'Lima', 'Yauyos', 'Huancaya', '151014', '0'),
('140713', 'Lima', 'Yauyos', 'Huangascar', '151015', '0'),
('140714', 'Lima', 'Yauyos', 'Huantan', '151016', '0'),
('140715', 'Lima', 'Yauyos', 'Huañec', '151017', '0'),
('140716', 'Lima', 'Yauyos', 'Laraos', '151018', '0'),
('140717', 'Lima', 'Yauyos', 'Lincha', '151019', '0'),
('140718', 'Lima', 'Yauyos', 'Miraflores', '151021', '0'),
('140719', 'Lima', 'Yauyos', 'Omas', '151022', '0'),
('140720', 'Lima', 'Yauyos', 'Quinches', '151024', '0'),
('140721', 'Lima', 'Yauyos', 'Quinocay', '151025', '0'),
('140722', 'Lima', 'Yauyos', 'San Joaquin', '151026', '0'),
('140723', 'Lima', 'Yauyos', 'San Pedro De Pilas', '151027', '0'),
('140724', 'Lima', 'Yauyos', 'Tanta', '151028', '0'),
('140725', 'Lima', 'Yauyos', 'Tauripampa', '151029', '0'),
('140726', 'Lima', 'Yauyos', 'Tupe', '151031', '0'),
('140727', 'Lima', 'Yauyos', 'Tomas', '151030', '0'),
('140728', 'Lima', 'Yauyos', 'Viñac', '151032', '0'),
('140729', 'Lima', 'Yauyos', 'Vitis', '151033', '0'),
('140730', 'Lima', 'Yauyos', 'Hongos', '151012', '0'),
('140731', 'Lima', 'Yauyos', 'Madean', '151020', '0'),
('140732', 'Lima', 'Yauyos', 'Putinza', '151023', '0'),
('140733', 'Lima', 'Yauyos', 'Catahuasi', '151008', '0'),
('140801', 'Lima', 'Huaral', 'Huaral', '150601', '0'),
('140802', 'Lima', 'Huaral', 'Atavillos Alto', '150602', '0'),
('140803', 'Lima', 'Huaral', 'Atavillos Bajo', '150603', '0'),
('140804', 'Lima', 'Huaral', 'Aucallama', '150604', '0'),
('140805', 'Lima', 'Huaral', 'Chancay', '150605', '0'),
('140806', 'Lima', 'Huaral', 'Ihuari', '150606', '0'),
('140807', 'Lima', 'Huaral', 'Lampian', '150607', '0'),
('140808', 'Lima', 'Huaral', 'Pacaraos', '150608', '0'),
('140809', 'Lima', 'Huaral', 'San Miguel De Acos', '150609', '0'),
('140810', 'Lima', 'Huaral', 'Veintisiete De Noviembre', '150612', '0'),
('140811', 'Lima', 'Huaral', 'Santa Cruz De Andamarca', '150610', '0'),
('140812', 'Lima', 'Huaral', 'Sumbilca', '150611', '0'),
('140901', 'Lima', 'Barranca', 'Barranca', '150201', '0'),
('140902', 'Lima', 'Barranca', 'Paramonga', '150202', '0'),
('140903', 'Lima', 'Barranca', 'Pativilca', '150203', '0'),
('140904', 'Lima', 'Barranca', 'Supe', '150204', '0'),
('140905', 'Lima', 'Barranca', 'Supe Puerto', '150205', '0'),
('141001', 'Lima', 'Oyon', 'Oyon', '150901', '0'),
('141002', 'Lima', 'Oyon', 'Navan', '150905', '0'),
('141003', 'Lima', 'Oyon', 'Caujul', '150903', '0'),
('141004', 'Lima', 'Oyon', 'Andajes', '150902', '0'),
('141005', 'Lima', 'Oyon', 'Pachangara', '150906', '0'),
('141006', 'Lima', 'Oyon', 'Cochamarca', '150904', '0'),
('150101', 'Loreto', 'Maynas', 'Iquitos', '160101', '0'),
('150102', 'Loreto', 'Maynas', 'Alto Nanay', '160102', '0'),
('150103', 'Loreto', 'Maynas', 'Fernando Lores', '160103', '0'),
('150104', 'Loreto', 'Maynas', 'Las Amazonas', '160105', '0'),
('150105', 'Loreto', 'Maynas', 'Mazan', '160106', '0'),
('150106', 'Loreto', 'Maynas', 'Napo', '160107', '0'),
('150107', 'Loreto', 'Maynas', 'Putumayo', '160109', '0'),
('150108', 'Loreto', 'Maynas', 'Torres Causana', '160110', '0'),
('150110', 'Loreto', 'Maynas', 'Indiana', '160104', '0'),
('150111', 'Loreto', 'Maynas', 'Punchana', '160108', '0'),
('150112', 'Loreto', 'Maynas', 'Belen', '160112', '0'),
('150113', 'Loreto', 'Maynas', 'San Juan Bautista', '160113', '0'),
('150114', 'Loreto', 'Maynas', 'Tnte Manuel Clavero', '160114', '0'),
('150201', 'Loreto', 'Alto Amazonas', 'Yurimaguas', '160201', '0'),
('150202', 'Loreto', 'Alto Amazonas', 'Balsa Puerto', '160202', '0'),
('150205', 'Loreto', 'Alto Amazonas', 'Jeberos', '160205', '0'),
('150206', 'Loreto', 'Alto Amazonas', 'Lagunas', '160206', '0'),
('150210', 'Loreto', 'Alto Amazonas', 'Santa Cruz', '160210', '0'),
('150211', 'Loreto', 'Alto Amazonas', 'Teniente Cesar Lopez Rojas', '160211', '0'),
('150301', 'Loreto', 'Loreto', 'Nauta', '160301', '0'),
('150302', 'Loreto', 'Loreto', 'Parinari', '160302', '0'),
('150303', 'Loreto', 'Loreto', 'Tigre', '160303', '0'),
('150304', 'Loreto', 'Loreto', 'Urarinas', '160305', '0'),
('150305', 'Loreto', 'Loreto', 'Trompeteros', '160304', '0'),
('150401', 'Loreto', 'Requena', 'Requena', '160501', '0'),
('150402', 'Loreto', 'Requena', 'Alto Tapiche', '160502', '0'),
('150403', 'Loreto', 'Requena', 'Capelo', '160503', '0'),
('150404', 'Loreto', 'Requena', 'Emilio San Martin', '160504', '0'),
('150405', 'Loreto', 'Requena', 'Maquia', '160505', '0'),
('150406', 'Loreto', 'Requena', 'Puinahua', '160506', '0'),
('150407', 'Loreto', 'Requena', 'Saquena', '160507', '0'),
('150408', 'Loreto', 'Requena', 'Soplin', '160508', '0'),
('150409', 'Loreto', 'Requena', 'Tapiche', '160509', '0'),
('150410', 'Loreto', 'Requena', 'Jenaro Herrera', '160510', '0'),
('150411', 'Loreto', 'Requena', 'Yaquerana', '160511', '0'),
('150501', 'Loreto', 'Ucayali', 'Contamana', '160601', '0'),
('150502', 'Loreto', 'Ucayali', 'Vargas Guerra', '160606', '0'),
('150503', 'Loreto', 'Ucayali', 'Padre Marquez', '160603', '0'),
('150504', 'Loreto', 'Ucayali', 'Pampa Hermosa', '160604', '0'),
('150505', 'Loreto', 'Ucayali', 'Sarayacu', '160605', '0'),
('150506', 'Loreto', 'Ucayali', 'Inahuaya', '160602', '0'),
('150601', 'Loreto', 'Mariscal Ramon Castilla', 'Ramon Castilla', '160401', '0'),
('150602', 'Loreto', 'Mariscal Ramon Castilla', 'Pebas', '160402', '0'),
('150603', 'Loreto', 'Mariscal Ramon Castilla', 'Yavari', '160403', '0'),
('150604', 'Loreto', 'Mariscal Ramon Castilla', 'San Pablo', '160404', '0'),
('150701', 'Loreto', 'Datem Del Marañon', 'Barranca', '160701', '0'),
('150702', 'Loreto', 'Datem Del Marañon', 'Andoas', '160706', '0'),
('150703', 'Loreto', 'Datem Del Marañon', 'Cahuapanas', '160702', '0'),
('150704', 'Loreto', 'Datem Del Marañon', 'Manseriche', '160703', '0'),
('150705', 'Loreto', 'Datem Del Marañon', 'Morona', '160704', '0'),
('150706', 'Loreto', 'Datem Del Marañon', 'Pastaza', '160705', '0'),
('160101', 'Madre De Dios', 'Tambopata', 'Tambopata', '170101', '0'),
('160102', 'Madre De Dios', 'Tambopata', 'Inambari', '170102', '0'),
('160103', 'Madre De Dios', 'Tambopata', 'Las Piedras', '170103', '0'),
('160104', 'Madre De Dios', 'Tambopata', 'Laberinto', '170104', '0'),
('160201', 'Madre De Dios', 'Manu', 'Manu', '170201', '0'),
('160202', 'Madre De Dios', 'Manu', 'Fitzcarrald', '170202', '0'),
('160203', 'Madre De Dios', 'Manu', 'Madre De Dios', '170203', '0'),
('160204', 'Madre De Dios', 'Manu', 'Huepetuhe', '170204', '0'),
('160301', 'Madre De Dios', 'Tahuamanu', 'Iñapari', '170301', '0'),
('160302', 'Madre De Dios', 'Tahuamanu', 'Iberia', '170302', '0'),
('160303', 'Madre De Dios', 'Tahuamanu', 'Tahuamanu', '170303', '0'),
('170101', 'Moquegua', 'Mariscal Nieto', 'Moquegua', '180101', '0'),
('170102', 'Moquegua', 'Mariscal Nieto', 'Carumas', '180102', '0'),
('170103', 'Moquegua', 'Mariscal Nieto', 'Cuchumbaya', '180103', '0'),
('170104', 'Moquegua', 'Mariscal Nieto', 'San Cristobal', '180105', '0'),
('170105', 'Moquegua', 'Mariscal Nieto', 'Torata', '180106', '0'),
('170106', 'Moquegua', 'Mariscal Nieto', 'Samegua', '180104', '0'),
('170201', 'Moquegua', 'General Sanchez Cerro', 'Omate', '180201', '0'),
('170202', 'Moquegua', 'General Sanchez Cerro', 'Coalaque', '180203', '0'),
('170203', 'Moquegua', 'General Sanchez Cerro', 'Chojata', '180202', '0'),
('170204', 'Moquegua', 'General Sanchez Cerro', 'Ichuña', '180204', '0'),
('170205', 'Moquegua', 'General Sanchez Cerro', 'La Capilla', '180205', '0'),
('170206', 'Moquegua', 'General Sanchez Cerro', 'Lloque', '180206', '0'),
('170207', 'Moquegua', 'General Sanchez Cerro', 'Matalaque', '180207', '0'),
('170208', 'Moquegua', 'General Sanchez Cerro', 'Puquina', '180208', '0'),
('170209', 'Moquegua', 'General Sanchez Cerro', 'Quinistaquillas', '180209', '0'),
('170210', 'Moquegua', 'General Sanchez Cerro', 'Ubinas', '180210', '0'),
('170211', 'Moquegua', 'General Sanchez Cerro', 'Yunga', '180211', '0'),
('170301', 'Moquegua', 'Ilo', 'Ilo', '180301', '0'),
('170302', 'Moquegua', 'Ilo', 'El Algarrobal', '180302', '0'),
('170303', 'Moquegua', 'Ilo', 'Pacocha', '180303', '0'),
('180101', 'Pasco', 'Pasco', 'Chaupimarca', '190101', '0'),
('180103', 'Pasco', 'Pasco', 'Huachon', '190102', '0'),
('180104', 'Pasco', 'Pasco', 'Huariaca', '190103', '0'),
('180105', 'Pasco', 'Pasco', 'Huayllay', '190104', '0'),
('180106', 'Pasco', 'Pasco', 'Ninacaca', '190105', '0'),
('180107', 'Pasco', 'Pasco', 'Pallanchacra', '190106', '0'),
('180108', 'Pasco', 'Pasco', 'Paucartambo', '190107', '0'),
('180109', 'Pasco', 'Pasco', 'San Francisco De Asis De Yarus', '190108', '0'),
('180110', 'Pasco', 'Pasco', 'Simon Bolivar', '190109', '0'),
('180111', 'Pasco', 'Pasco', 'Ticlacayan', '190110', '0'),
('180112', 'Pasco', 'Pasco', 'Tinyahuarco', '190111', '0'),
('180113', 'Pasco', 'Pasco', 'Vicco', '190112', '0'),
('180114', 'Pasco', 'Pasco', 'Yanacancha', '190113', '0'),
('180201', 'Pasco', 'Daniel Alcides Carrion', 'Yanahuanca', '190201', '0'),
('180202', 'Pasco', 'Daniel Alcides Carrion', 'Chacayan', '190202', '0'),
('180203', 'Pasco', 'Daniel Alcides Carrion', 'Goyllarisquizga', '190203', '0'),
('180204', 'Pasco', 'Daniel Alcides Carrion', 'Paucar', '190204', '0'),
('180205', 'Pasco', 'Daniel Alcides Carrion', 'San Pedro De Pillao', '190205', '0'),
('180206', 'Pasco', 'Daniel Alcides Carrion', 'Santa Ana De Tusi', '190206', '0'),
('180207', 'Pasco', 'Daniel Alcides Carrion', 'Tapuc', '190207', '0'),
('180208', 'Pasco', 'Daniel Alcides Carrion', 'Vilcabamba', '190208', '0'),
('180301', 'Pasco', 'Oxapampa', 'Oxapampa', '190301', '0'),
('180302', 'Pasco', 'Oxapampa', 'Chontabamba', '190302', '0'),
('180303', 'Pasco', 'Oxapampa', 'Huancabamba', '190303', '0'),
('180304', 'Pasco', 'Oxapampa', 'Puerto Bermudez', '190306', '0'),
('180305', 'Pasco', 'Oxapampa', 'Villa Rica', '190307', '0'),
('180306', 'Pasco', 'Oxapampa', 'Pozuzo', '190305', '0'),
('180307', 'Pasco', 'Oxapampa', 'Palcazu', '190304', '0'),
('190101', 'Piura', 'Piura', 'Piura', '200101', '0'),
('190103', 'Piura', 'Piura', 'Castilla', '200104', '0'),
('190104', 'Piura', 'Piura', 'Catacaos', '200105', '0'),
('190105', 'Piura', 'Piura', 'La Arena', '200109', '0'),
('190106', 'Piura', 'Piura', 'La Union', '200110', '0'),
('190107', 'Piura', 'Piura', 'Las Lomas', '200111', '0'),
('190109', 'Piura', 'Piura', 'Tambo Grande', '200114', '0'),
('190113', 'Piura', 'Piura', 'Cura Mori', '200107', '0'),
('190114', 'Piura', 'Piura', 'El Tallan', '200108', '0'),
('190201', 'Piura', 'Ayabaca', 'Ayabaca', '200201', '1'),
('190202', 'Piura', 'Ayabaca', 'Frias', '200202', '1'),
('190203', 'Piura', 'Ayabaca', 'Lagunas', '200204', '1'),
('190204', 'Piura', 'Ayabaca', 'Montero', '200205', '1'),
('190205', 'Piura', 'Ayabaca', 'Pacaipampa', '200206', '1'),
('190206', 'Piura', 'Ayabaca', 'Sapillica', '200208', '1'),
('190207', 'Piura', 'Ayabaca', 'Sicchez', '200209', '1'),
('190208', 'Piura', 'Ayabaca', 'Suyo', '200210', '1'),
('190209', 'Piura', 'Ayabaca', 'Jilili', '200203', '1'),
('190210', 'Piura', 'Ayabaca', 'Paimas', '200207', '1'),
('190301', 'Piura', 'Huancabamba', 'Huancabamba', '200301', '1'),
('190302', 'Piura', 'Huancabamba', 'Canchaque', '200302', '1'),
('190303', 'Piura', 'Huancabamba', 'Huarmaca', '200304', '1'),
('190304', 'Piura', 'Huancabamba', 'Sondor', '200307', '1'),
('190305', 'Piura', 'Huancabamba', 'Sondorillo', '200308', '1'),
('190306', 'Piura', 'Huancabamba', 'El Carmen De La Frontera', '200303', '1'),
('190307', 'Piura', 'Huancabamba', 'San Miguel De El Faique', '200306', '1'),
('190308', 'Piura', 'Huancabamba', 'Lalaquiz', '200305', '1'),
('190401', 'Piura', 'Morropon', 'Chulucanas', '200401', '1'),
('190402', 'Piura', 'Morropon', 'Buenos Aires', '200402', '1'),
('190403', 'Piura', 'Morropon', 'Chalaco', '200403', '1'),
('190404', 'Piura', 'Morropon', 'Morropon', '200405', '1'),
('190405', 'Piura', 'Morropon', 'Salitral', '200406', '1'),
('190406', 'Piura', 'Morropon', 'Santa Catalina De Mossa', '200408', '1'),
('190407', 'Piura', 'Morropon', 'Santo Domingo', '200409', '1'),
('190408', 'Piura', 'Morropon', 'La Matanza', '200404', '1'),
('190409', 'Piura', 'Morropon', 'Yamango', '200410', '1'),
('190410', 'Piura', 'Morropon', 'San Juan De Bigote', '200407', '1'),
('190501', 'Piura', 'Paita', 'Paita', '200501', '1'),
('190502', 'Piura', 'Paita', 'Amotape', '200502', '1'),
('190503', 'Piura', 'Paita', 'Arenal', '200503', '1'),
('190504', 'Piura', 'Paita', 'La Huaca', '200505', '1'),
('190505', 'Piura', 'Paita', 'Colan', '200504', '1'),
('190506', 'Piura', 'Paita', 'Tamarindo', '200506', '1'),
('190507', 'Piura', 'Paita', 'Vichayal', '200507', '1'),
('190601', 'Piura', 'Sullana', 'Sullana', '200601', '1'),
('190602', 'Piura', 'Sullana', 'Bellavista', '200602', '1'),
('190603', 'Piura', 'Sullana', 'Lancones', '200604', '1'),
('190604', 'Piura', 'Sullana', 'Marcavelica', '200605', '1'),
('190605', 'Piura', 'Sullana', 'Miguel Checa', '200606', '1'),
('190606', 'Piura', 'Sullana', 'Querecotillo', '200607', '1'),
('190607', 'Piura', 'Sullana', 'Salitral', '200608', '1'),
('190608', 'Piura', 'Sullana', 'Ignacio Escudero', '200603', '1'),
('190701', 'Piura', 'Talara', 'Pariñas', '200701', '1'),
('190702', 'Piura', 'Talara', 'El Alto', '200702', '1'),
('190703', 'Piura', 'Talara', 'La Brea', '200703', '1'),
('190704', 'Piura', 'Talara', 'Lobitos', '200704', '1'),
('190705', 'Piura', 'Talara', 'Mancora', '200706', '1'),
('190706', 'Piura', 'Talara', 'Los Organos', '200705', '1'),
('190801', 'Piura', 'Sechura', 'Sechura', '200801', '1'),
('190802', 'Piura', 'Sechura', 'Vice', '200805', '1'),
('190803', 'Piura', 'Sechura', 'Bernal', '200803', '1'),
('190804', 'Piura', 'Sechura', 'Bellavista De La Union', '200802', '1'),
('190805', 'Piura', 'Sechura', 'Cristo Nos Valga', '200804', '1'),
('190806', 'Piura', 'Sechura', 'Rinconada-llicuar', '200806', '1'),
('200101', 'Puno', 'Puno', 'Puno', '210101', '0'),
('200102', 'Puno', 'Puno', 'Acora', '210102', '0'),
('200103', 'Puno', 'Puno', 'Atuncolla', '210104', '0'),
('200104', 'Puno', 'Puno', 'Capachica', '210105', '0'),
('200105', 'Puno', 'Puno', 'Coata', '210107', '0'),
('200106', 'Puno', 'Puno', 'Chucuito', '210106', '0'),
('200107', 'Puno', 'Puno', 'Huata', '210108', '0'),
('200108', 'Puno', 'Puno', 'Mañazo', '210109', '0'),
('200109', 'Puno', 'Puno', 'Paucarcolla', '210110', '0'),
('200110', 'Puno', 'Puno', 'Pichacani', '210111', '0'),
('200111', 'Puno', 'Puno', 'San Antonio', '210113', '0'),
('200112', 'Puno', 'Puno', 'Tiquillaca', '210114', '0'),
('200113', 'Puno', 'Puno', 'Vilque', '210115', '0'),
('200114', 'Puno', 'Puno', 'Plateria', '210112', '0'),
('200115', 'Puno', 'Puno', 'Amantani', '210103', '0'),
('200201', 'Puno', 'Azangaro', 'Azangaro', '210201', '1'),
('200202', 'Puno', 'Azangaro', 'Achaya', '210202', '1'),
('200203', 'Puno', 'Azangaro', 'Arapa', '210203', '1'),
('200204', 'Puno', 'Azangaro', 'Asillo', '210204', '1'),
('200205', 'Puno', 'Azangaro', 'Caminaca', '210205', '1'),
('200206', 'Puno', 'Azangaro', 'Chupa', '210206', '1'),
('200207', 'Puno', 'Azangaro', 'Jose Domingo Choquehuanca', '210207', '1'),
('200208', 'Puno', 'Azangaro', 'Muñani', '210208', '1'),
('200210', 'Puno', 'Azangaro', 'Potoni', '210209', '1'),
('200212', 'Puno', 'Azangaro', 'Saman', '210210', '1'),
('200213', 'Puno', 'Azangaro', 'San Anton', '210211', '1'),
('200214', 'Puno', 'Azangaro', 'San Jose', '210212', '1'),
('200215', 'Puno', 'Azangaro', 'San Juan De Salinas', '210213', '1'),
('200216', 'Puno', 'Azangaro', 'Santiago De Pupuja', '210214', '1'),
('200217', 'Puno', 'Azangaro', 'Tirapata', '210215', '1'),
('200301', 'Puno', 'Carabaya', 'Macusani', '210301', '1'),
('200302', 'Puno', 'Carabaya', 'Ajoyani', '210302', '1'),
('200303', 'Puno', 'Carabaya', 'Ayapata', '210303', '1'),
('200304', 'Puno', 'Carabaya', 'Coasa', '210304', '1'),
('200305', 'Puno', 'Carabaya', 'Corani', '210305', '1'),
('200306', 'Puno', 'Carabaya', 'Crucero', '210306', '1'),
('200307', 'Puno', 'Carabaya', 'Ituata', '210307', '1'),
('200308', 'Puno', 'Carabaya', 'Ollachea', '210308', '1'),
('200309', 'Puno', 'Carabaya', 'San Gaban', '210309', '1'),
('200310', 'Puno', 'Carabaya', 'Usicayos', '210310', '1'),
('200401', 'Puno', 'Chucuito', 'Juli', '210401', '1');
INSERT INTO `ubigeo` (`ubigeo1`, `dpto`, `prov`, `distrito`, `ubigeo2`, `orden`) VALUES
('200402', 'Puno', 'Chucuito', 'Desaguadero', '210402', '1'),
('200403', 'Puno', 'Chucuito', 'Huacullani', '210403', '1'),
('200406', 'Puno', 'Chucuito', 'Pisacoma', '210405', '1'),
('200407', 'Puno', 'Chucuito', 'Pomata', '210406', '1'),
('200410', 'Puno', 'Chucuito', 'Zepita', '210407', '1'),
('200412', 'Puno', 'Chucuito', 'Kelluyo', '210404', '1'),
('200501', 'Puno', 'Huancane', 'Huancane', '210601', '1'),
('200502', 'Puno', 'Huancane', 'Cojata', '210602', '1'),
('200504', 'Puno', 'Huancane', 'Inchupalla', '210604', '1'),
('200506', 'Puno', 'Huancane', 'Pusi', '210605', '1'),
('200507', 'Puno', 'Huancane', 'Rosaspata', '210606', '1'),
('200508', 'Puno', 'Huancane', 'Taraco', '210607', '1'),
('200509', 'Puno', 'Huancane', 'Vilque Chico', '210608', '1'),
('200511', 'Puno', 'Huancane', 'Huatasani', '210603', '1'),
('200601', 'Puno', 'Lampa', 'Lampa', '210701', '1'),
('200602', 'Puno', 'Lampa', 'Cabanilla', '210702', '1'),
('200603', 'Puno', 'Lampa', 'Calapuja', '210703', '1'),
('200604', 'Puno', 'Lampa', 'Nicasio', '210704', '1'),
('200605', 'Puno', 'Lampa', 'Ocuviri', '210705', '1'),
('200606', 'Puno', 'Lampa', 'Palca', '210706', '1'),
('200607', 'Puno', 'Lampa', 'Paratia', '210707', '1'),
('200608', 'Puno', 'Lampa', 'Pucara', '210708', '1'),
('200609', 'Puno', 'Lampa', 'Santa Lucia', '210709', '1'),
('200610', 'Puno', 'Lampa', 'Vilavila', '210710', '1'),
('200701', 'Puno', 'Melgar', 'Ayaviri', '210801', '1'),
('200702', 'Puno', 'Melgar', 'Antauta', '210802', '1'),
('200703', 'Puno', 'Melgar', 'Cupi', '210803', '1'),
('200704', 'Puno', 'Melgar', 'Llalli', '210804', '1'),
('200705', 'Puno', 'Melgar', 'Macari', '210805', '1'),
('200706', 'Puno', 'Melgar', 'Nuñoa', '210806', '1'),
('200707', 'Puno', 'Melgar', 'Orurillo', '210807', '1'),
('200708', 'Puno', 'Melgar', 'Santa Rosa', '210808', '1'),
('200709', 'Puno', 'Melgar', 'Umachiri', '210809', '1'),
('200801', 'Puno', 'Sandia', 'Sandia', '211201', '1'),
('200803', 'Puno', 'Sandia', 'Cuyocuyo', '211202', '1'),
('200804', 'Puno', 'Sandia', 'Limbani', '211203', '1'),
('200805', 'Puno', 'Sandia', 'Phara', '211205', '1'),
('200806', 'Puno', 'Sandia', 'Patambuco', '211204', '1'),
('200807', 'Puno', 'Sandia', 'Quiaca', '211206', '1'),
('200808', 'Puno', 'Sandia', 'San Juan Del Oro', '211207', '1'),
('200810', 'Puno', 'Sandia', 'Yanahuaya', '211208', '1'),
('200811', 'Puno', 'Sandia', 'Alto Inambari', '211209', '1'),
('200812', 'Puno', 'Sandia', 'San Pedro De Putina Punco', '211210', '1'),
('200901', 'Puno', 'San Roman', 'Juliaca', '211101', '1'),
('200902', 'Puno', 'San Roman', 'Cabana', '211102', '1'),
('200903', 'Puno', 'San Roman', 'Cabanillas', '211103', '1'),
('200904', 'Puno', 'San Roman', 'Caracoto', '211104', '1'),
('201001', 'Puno', 'Yunguyo', 'Yunguyo', '211301', '1'),
('201002', 'Puno', 'Yunguyo', 'Unicachi', '211307', '1'),
('201003', 'Puno', 'Yunguyo', 'Anapia', '211302', '1'),
('201004', 'Puno', 'Yunguyo', 'Copani', '211303', '1'),
('201005', 'Puno', 'Yunguyo', 'Cuturapi', '211304', '1'),
('201006', 'Puno', 'Yunguyo', 'Ollaraya', '211305', '1'),
('201007', 'Puno', 'Yunguyo', 'Tinicachi', '211306', '1'),
('201101', 'Puno', 'San Antonio De Putina', 'Putina', '211001', '1'),
('201102', 'Puno', 'San Antonio De Putina', 'Pedro Vilca Apaza', '211003', '1'),
('201103', 'Puno', 'San Antonio De Putina', 'Quilcapuncu', '211004', '1'),
('201104', 'Puno', 'San Antonio De Putina', 'Ananea', '211002', '1'),
('201105', 'Puno', 'San Antonio De Putina', 'Sina', '211005', '1'),
('201201', 'Puno', 'El Collao', 'Ilave', '210501', '1'),
('201202', 'Puno', 'El Collao', 'Pilcuyo', '210503', '1'),
('201203', 'Puno', 'El Collao', 'Santa Rosa', '210504', '1'),
('201204', 'Puno', 'El Collao', 'Capaso', '210502', '1'),
('201205', 'Puno', 'El Collao', 'Conduriri', '210505', '1'),
('201301', 'Puno', 'Moho', 'Moho', '210901', '1'),
('201302', 'Puno', 'Moho', 'Conima', '210902', '1'),
('201303', 'Puno', 'Moho', 'Tilali', '210904', '1'),
('201304', 'Puno', 'Moho', 'Huayrapata', '210903', '1'),
('210101', 'San Martin', 'Moyobamba', 'Moyobamba', '220101', '0'),
('210102', 'San Martin', 'Moyobamba', 'Calzada', '220102', '0'),
('210103', 'San Martin', 'Moyobamba', 'Habana', '220103', '0'),
('210104', 'San Martin', 'Moyobamba', 'Jepelacio', '220104', '0'),
('210105', 'San Martin', 'Moyobamba', 'Soritor', '220105', '0'),
('210106', 'San Martin', 'Moyobamba', 'Yantalo', '220106', '0'),
('210201', 'San Martin', 'Huallaga', 'Saposoa', '220401', '0'),
('210202', 'San Martin', 'Huallaga', 'Piscoyacu', '220404', '0'),
('210203', 'San Martin', 'Huallaga', 'Sacanche', '220405', '0'),
('210204', 'San Martin', 'Huallaga', 'Tingo De Saposoa', '220406', '0'),
('210205', 'San Martin', 'Huallaga', 'Alto Saposoa', '220402', '0'),
('210206', 'San Martin', 'Huallaga', 'El Eslabon', '220403', '0'),
('210301', 'San Martin', 'Lamas', 'Lamas', '220501', '0'),
('210303', 'San Martin', 'Lamas', 'Barranquita', '220503', '0'),
('210304', 'San Martin', 'Lamas', 'Caynarachi', '220504', '0'),
('210305', 'San Martin', 'Lamas', 'Cuñumbuqui', '220505', '0'),
('210306', 'San Martin', 'Lamas', 'Pinto Recodo', '220506', '0'),
('210307', 'San Martin', 'Lamas', 'Rumisapa', '220507', '0'),
('210311', 'San Martin', 'Lamas', 'Shanao', '220509', '0'),
('210313', 'San Martin', 'Lamas', 'Tabalosos', '220510', '0'),
('210314', 'San Martin', 'Lamas', 'Zapatero', '220511', '0'),
('210315', 'San Martin', 'Lamas', 'Alonso De Alvarado', '220502', '0'),
('210316', 'San Martin', 'Lamas', 'San Roque De Cumbaza', '220508', '0'),
('210401', 'San Martin', 'Mariscal Caceres', 'Juanjui', '220601', '0'),
('210402', 'San Martin', 'Mariscal Caceres', 'Campanilla', '220602', '0'),
('210403', 'San Martin', 'Mariscal Caceres', 'Huicungo', '220603', '0'),
('210404', 'San Martin', 'Mariscal Caceres', 'Pachiza', '220604', '0'),
('210405', 'San Martin', 'Mariscal Caceres', 'Pajarillo', '220605', '0'),
('210501', 'San Martin', 'Rioja', 'Rioja', '220801', '0'),
('210502', 'San Martin', 'Rioja', 'Posic', '220806', '0'),
('210503', 'San Martin', 'Rioja', 'Yorongos', '220808', '0'),
('210504', 'San Martin', 'Rioja', 'Yuracyacu', '220809', '0'),
('210505', 'San Martin', 'Rioja', 'Nueva Cajamarca', '220804', '0'),
('210506', 'San Martin', 'Rioja', 'Elias Soplin', '220803', '0'),
('210507', 'San Martin', 'Rioja', 'San Fernando', '220807', '0'),
('210508', 'San Martin', 'Rioja', 'Pardo Miguel', '220805', '0'),
('210509', 'San Martin', 'Rioja', 'Awajun', '220802', '0'),
('210601', 'San Martin', 'San Martin', 'Tarapoto', '220901', '0'),
('210602', 'San Martin', 'San Martin', 'Alberto Leveau', '220902', '0'),
('210604', 'San Martin', 'San Martin', 'Cacatachi', '220903', '0'),
('210606', 'San Martin', 'San Martin', 'Chazuta', '220904', '0'),
('210607', 'San Martin', 'San Martin', 'Chipurana', '220905', '0'),
('210608', 'San Martin', 'San Martin', 'El Porvenir', '220906', '0'),
('210609', 'San Martin', 'San Martin', 'Huimbayoc', '220907', '0'),
('210610', 'San Martin', 'San Martin', 'Juan Guerra', '220908', '0'),
('210611', 'San Martin', 'San Martin', 'Morales', '220910', '0'),
('210612', 'San Martin', 'San Martin', 'Papa-playa', '220911', '0'),
('210616', 'San Martin', 'San Martin', 'San Antonio', '220912', '0'),
('210619', 'San Martin', 'San Martin', 'Sauce', '220913', '0'),
('210620', 'San Martin', 'San Martin', 'Shapaja', '220914', '0'),
('210621', 'San Martin', 'San Martin', 'La Banda De Shilcayo', '220909', '0'),
('210701', 'San Martin', 'Bellavista', 'Bellavista', '220201', '0'),
('210702', 'San Martin', 'Bellavista', 'San Rafael', '220206', '0'),
('210703', 'San Martin', 'Bellavista', 'San Pablo', '220205', '0'),
('210704', 'San Martin', 'Bellavista', 'Alto Biavo', '220202', '0'),
('210705', 'San Martin', 'Bellavista', 'Huallaga', '220204', '0'),
('210706', 'San Martin', 'Bellavista', 'Bajo Biavo', '220203', '0'),
('210801', 'San Martin', 'Tocache', 'Tocache', '221001', '0'),
('210802', 'San Martin', 'Tocache', 'Nuevo Progreso', '221002', '0'),
('210803', 'San Martin', 'Tocache', 'Polvora', '221003', '0'),
('210804', 'San Martin', 'Tocache', 'Shunte', '221004', '0'),
('210805', 'San Martin', 'Tocache', 'Uchiza', '221005', '0'),
('210901', 'San Martin', 'Picota', 'Picota', '220701', '0'),
('210902', 'San Martin', 'Picota', 'Buenos Aires', '220702', '0'),
('210903', 'San Martin', 'Picota', 'Caspizapa', '220703', '0'),
('210904', 'San Martin', 'Picota', 'Pilluana', '220704', '0'),
('210905', 'San Martin', 'Picota', 'Pucacaca', '220705', '0'),
('210906', 'San Martin', 'Picota', 'San Cristobal', '220706', '0'),
('210907', 'San Martin', 'Picota', 'San Hilarion', '220707', '0'),
('210908', 'San Martin', 'Picota', 'Tingo De Ponasa', '220709', '0'),
('210909', 'San Martin', 'Picota', 'Tres Unidos', '220710', '0'),
('210910', 'San Martin', 'Picota', 'Shamboyacu', '220708', '0'),
('211001', 'San Martin', 'El Dorado', 'San Jose De Sisa', '220301', '0'),
('211002', 'San Martin', 'El Dorado', 'Agua Blanca', '220302', '0'),
('211003', 'San Martin', 'El Dorado', 'Shatoja', '220305', '0'),
('211004', 'San Martin', 'El Dorado', 'San Martin', '220303', '0'),
('211005', 'San Martin', 'El Dorado', 'Santa Rosa', '220304', '0'),
('220101', 'Tacna', 'Tacna', 'Tacna', '230101', '0'),
('220102', 'Tacna', 'Tacna', 'Calana', '230103', '0'),
('220104', 'Tacna', 'Tacna', 'Inclan', '230105', '0'),
('220107', 'Tacna', 'Tacna', 'Pachia', '230106', '0'),
('220108', 'Tacna', 'Tacna', 'Palca', '230107', '0'),
('220109', 'Tacna', 'Tacna', 'Pocollay', '230108', '0'),
('220110', 'Tacna', 'Tacna', 'Sama', '230109', '0'),
('220111', 'Tacna', 'Tacna', 'Alto De La Alianza', '230102', '0'),
('220112', 'Tacna', 'Tacna', 'Ciudad Nueva', '230104', '0'),
('220113', 'Tacna', 'Tacna', 'Coronel Gregorio Albarracin La', '230110', '0'),
('220201', 'Tacna', 'Tarata', 'Tarata', '230401', '1'),
('220205', 'Tacna', 'Tarata', 'Heroes Albarracin', '230402', '1'),
('220206', 'Tacna', 'Tarata', 'Estique', '230403', '1'),
('220207', 'Tacna', 'Tarata', 'Estique Pampa', '230404', '1'),
('220210', 'Tacna', 'Tarata', 'Sitajara', '230405', '1'),
('220211', 'Tacna', 'Tarata', 'Susapaya', '230406', '1'),
('220212', 'Tacna', 'Tarata', 'Tarucachi', '230407', '1'),
('220213', 'Tacna', 'Tarata', 'Ticaco', '230408', '1'),
('220301', 'Tacna', 'Jorge Basadre', 'Locumba', '230301', '1'),
('220302', 'Tacna', 'Jorge Basadre', 'Ite', '230303', '1'),
('220303', 'Tacna', 'Jorge Basadre', 'Ilabaya', '230302', '1'),
('220401', 'Tacna', 'Candarave', 'Candarave', '230201', '1'),
('220402', 'Tacna', 'Candarave', 'Cairani', '230202', '1'),
('220403', 'Tacna', 'Candarave', 'Curibaya', '230204', '1'),
('220404', 'Tacna', 'Candarave', 'Huanuara', '230205', '1'),
('220405', 'Tacna', 'Candarave', 'Quilahuani', '230206', '1'),
('220406', 'Tacna', 'Candarave', 'Camilaca', '230203', '1'),
('230101', 'Tumbes', 'Tumbes', 'Tumbes', '240101', '0'),
('230102', 'Tumbes', 'Tumbes', 'Corrales', '240102', '0'),
('230103', 'Tumbes', 'Tumbes', 'La Cruz', '240103', '0'),
('230104', 'Tumbes', 'Tumbes', 'Pampas De Hospital', '240104', '0'),
('230105', 'Tumbes', 'Tumbes', 'San Jacinto', '240105', '0'),
('230106', 'Tumbes', 'Tumbes', 'San Juan De La Virgen', '240106', '0'),
('230201', 'Tumbes', 'Contralmirante Villar', 'Zorritos', '240201', '0'),
('230202', 'Tumbes', 'Contralmirante Villar', 'Casitas', '240202', '0'),
('230203', 'Tumbes', 'Contralmirante Villar', 'Canoas De Punta Sal', '240203', '0'),
('230301', 'Tumbes', 'Zarumilla', 'Zarumilla', '240301', '0'),
('230302', 'Tumbes', 'Zarumilla', 'Matapalo', '240303', '0'),
('230303', 'Tumbes', 'Zarumilla', 'Papayal', '240304', '0'),
('230304', 'Tumbes', 'Zarumilla', 'Aguas Verdes', '240302', '0'),
('240101', 'Callao', 'Callao', 'Callao', '070101', '0'),
('240102', 'Callao', 'Callao', 'Bellavista', '070102', '0'),
('240103', 'Callao', 'Callao', 'La Punta', '070105', '0'),
('240104', 'Callao', 'Callao', 'Carmen De La Legua Reynoso', '070103', '0'),
('240105', 'Callao', 'Callao', 'La Perla', '070104', '0'),
('240106', 'Callao', 'Callao', 'Ventanilla', '070106', '0'),
('250101', 'Ucayali', 'Coronel Portillo', 'Calleria', '250101', '0'),
('250102', 'Ucayali', 'Coronel Portillo', 'Yarinacocha', '250105', '0'),
('250103', 'Ucayali', 'Coronel Portillo', 'Masisea', '250104', '0'),
('250104', 'Ucayali', 'Coronel Portillo', 'Campoverde', '250102', '0'),
('250105', 'Ucayali', 'Coronel Portillo', 'Iparia', '250103', '0'),
('250106', 'Ucayali', 'Coronel Portillo', 'Nueva Requena', '250106', '0'),
('250107', 'Ucayali', 'Coronel Portillo', 'Manantay', '250107', '0'),
('250201', 'Ucayali', 'Padre Abad', 'Padre Abad', '250301', '1'),
('250202', 'Ucayali', 'Padre Abad', 'Irazola', '250302', '1'),
('250203', 'Ucayali', 'Padre Abad', 'Curimana', '250303', '1'),
('250301', 'Ucayali', 'Atalaya', 'Raimondi', '250201', '1'),
('250302', 'Ucayali', 'Atalaya', 'Tahuania', '250203', '1'),
('250303', 'Ucayali', 'Atalaya', 'Yurua', '250204', '1'),
('250304', 'Ucayali', 'Atalaya', 'Sepahua', '250202', '1'),
('250401', 'Ucayali', 'Purus', 'Purus', '250401', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ubigeo_peru_departments`
--

CREATE TABLE `ubigeo_peru_departments` (
  `id` varchar(2) NOT NULL,
  `name` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `ubigeo_peru_departments`
--

INSERT INTO `ubigeo_peru_departments` (`id`, `name`) VALUES
('01', 'Amazonas'),
('02', 'Áncash'),
('03', 'Apurímac'),
('04', 'Arequipa'),
('05', 'Ayacucho'),
('06', 'Cajamarca'),
('07', 'Callao'),
('08', 'Cusco'),
('09', 'Huancavelica'),
('10', 'Huánuco'),
('11', 'Ica'),
('12', 'Junín'),
('13', 'La Libertad'),
('14', 'Lambayeque'),
('15', 'Lima'),
('16', 'Loreto'),
('17', 'Madre de Dios'),
('18', 'Moquegua'),
('19', 'Pasco'),
('20', 'Piura'),
('21', 'Puno'),
('22', 'San Martín'),
('23', 'Tacna'),
('24', 'Tumbes'),
('25', 'Ucayali');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ubigeo_peru_districts`
--

CREATE TABLE `ubigeo_peru_districts` (
  `id` varchar(6) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `province_id` varchar(4) DEFAULT NULL,
  `department_id` varchar(2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `ubigeo_peru_districts`
--

INSERT INTO `ubigeo_peru_districts` (`id`, `name`, `province_id`, `department_id`) VALUES
('010101', 'Chachapoyas', '0101', '01'),
('010102', 'Asunción', '0101', '01'),
('010103', 'Balsas', '0101', '01'),
('010104', 'Cheto', '0101', '01'),
('010105', 'Chiliquin', '0101', '01'),
('010106', 'Chuquibamba', '0101', '01'),
('010107', 'Granada', '0101', '01'),
('010108', 'Huancas', '0101', '01'),
('010109', 'La Jalca', '0101', '01'),
('010110', 'Leimebamba', '0101', '01'),
('010111', 'Levanto', '0101', '01'),
('010112', 'Magdalena', '0101', '01'),
('010113', 'Mariscal Castilla', '0101', '01'),
('010114', 'Molinopampa', '0101', '01'),
('010115', 'Montevideo', '0101', '01'),
('010116', 'Olleros', '0101', '01'),
('010117', 'Quinjalca', '0101', '01'),
('010118', 'San Francisco de Daguas', '0101', '01'),
('010119', 'San Isidro de Maino', '0101', '01'),
('010120', 'Soloco', '0101', '01'),
('010121', 'Sonche', '0101', '01'),
('010201', 'Bagua', '0102', '01'),
('010202', 'Aramango', '0102', '01'),
('010203', 'Copallin', '0102', '01'),
('010204', 'El Parco', '0102', '01'),
('010205', 'Imaza', '0102', '01'),
('010206', 'La Peca', '0102', '01'),
('010301', 'Jumbilla', '0103', '01'),
('010302', 'Chisquilla', '0103', '01'),
('010303', 'Churuja', '0103', '01'),
('010304', 'Corosha', '0103', '01'),
('010305', 'Cuispes', '0103', '01'),
('010306', 'Florida', '0103', '01'),
('010307', 'Jazan', '0103', '01'),
('010308', 'Recta', '0103', '01'),
('010309', 'San Carlos', '0103', '01'),
('010310', 'Shipasbamba', '0103', '01'),
('010311', 'Valera', '0103', '01'),
('010312', 'Yambrasbamba', '0103', '01'),
('010401', 'Nieva', '0104', '01'),
('010402', 'El Cenepa', '0104', '01'),
('010403', 'Río Santiago', '0104', '01'),
('010501', 'Lamud', '0105', '01'),
('010502', 'Camporredondo', '0105', '01'),
('010503', 'Cocabamba', '0105', '01'),
('010504', 'Colcamar', '0105', '01'),
('010505', 'Conila', '0105', '01'),
('010506', 'Inguilpata', '0105', '01'),
('010507', 'Longuita', '0105', '01'),
('010508', 'Lonya Chico', '0105', '01'),
('010509', 'Luya', '0105', '01'),
('010510', 'Luya Viejo', '0105', '01'),
('010511', 'María', '0105', '01'),
('010512', 'Ocalli', '0105', '01'),
('010513', 'Ocumal', '0105', '01'),
('010514', 'Pisuquia', '0105', '01'),
('010515', 'Providencia', '0105', '01'),
('010516', 'San Cristóbal', '0105', '01'),
('010517', 'San Francisco de Yeso', '0105', '01'),
('010518', 'San Jerónimo', '0105', '01'),
('010519', 'San Juan de Lopecancha', '0105', '01'),
('010520', 'Santa Catalina', '0105', '01'),
('010521', 'Santo Tomas', '0105', '01'),
('010522', 'Tingo', '0105', '01'),
('010523', 'Trita', '0105', '01'),
('010601', 'San Nicolás', '0106', '01'),
('010602', 'Chirimoto', '0106', '01'),
('010603', 'Cochamal', '0106', '01'),
('010604', 'Huambo', '0106', '01'),
('010605', 'Limabamba', '0106', '01'),
('010606', 'Longar', '0106', '01'),
('010607', 'Mariscal Benavides', '0106', '01'),
('010608', 'Milpuc', '0106', '01'),
('010609', 'Omia', '0106', '01'),
('010610', 'Santa Rosa', '0106', '01'),
('010611', 'Totora', '0106', '01'),
('010612', 'Vista Alegre', '0106', '01'),
('010701', 'Bagua Grande', '0107', '01'),
('010702', 'Cajaruro', '0107', '01'),
('010703', 'Cumba', '0107', '01'),
('010704', 'El Milagro', '0107', '01'),
('010705', 'Jamalca', '0107', '01'),
('010706', 'Lonya Grande', '0107', '01'),
('010707', 'Yamon', '0107', '01'),
('020101', 'Huaraz', '0201', '02'),
('020102', 'Cochabamba', '0201', '02'),
('020103', 'Colcabamba', '0201', '02'),
('020104', 'Huanchay', '0201', '02'),
('020105', 'Independencia', '0201', '02'),
('020106', 'Jangas', '0201', '02'),
('020107', 'La Libertad', '0201', '02'),
('020108', 'Olleros', '0201', '02'),
('020109', 'Pampas Grande', '0201', '02'),
('020110', 'Pariacoto', '0201', '02'),
('020111', 'Pira', '0201', '02'),
('020112', 'Tarica', '0201', '02'),
('020201', 'Aija', '0202', '02'),
('020202', 'Coris', '0202', '02'),
('020203', 'Huacllan', '0202', '02'),
('020204', 'La Merced', '0202', '02'),
('020205', 'Succha', '0202', '02'),
('020301', 'Llamellin', '0203', '02'),
('020302', 'Aczo', '0203', '02'),
('020303', 'Chaccho', '0203', '02'),
('020304', 'Chingas', '0203', '02'),
('020305', 'Mirgas', '0203', '02'),
('020306', 'San Juan de Rontoy', '0203', '02'),
('020401', 'Chacas', '0204', '02'),
('020402', 'Acochaca', '0204', '02'),
('020501', 'Chiquian', '0205', '02'),
('020502', 'Abelardo Pardo Lezameta', '0205', '02'),
('020503', 'Antonio Raymondi', '0205', '02'),
('020504', 'Aquia', '0205', '02'),
('020505', 'Cajacay', '0205', '02'),
('020506', 'Canis', '0205', '02'),
('020507', 'Colquioc', '0205', '02'),
('020508', 'Huallanca', '0205', '02'),
('020509', 'Huasta', '0205', '02'),
('020510', 'Huayllacayan', '0205', '02'),
('020511', 'La Primavera', '0205', '02'),
('020512', 'Mangas', '0205', '02'),
('020513', 'Pacllon', '0205', '02'),
('020514', 'San Miguel de Corpanqui', '0205', '02'),
('020515', 'Ticllos', '0205', '02'),
('020601', 'Carhuaz', '0206', '02'),
('020602', 'Acopampa', '0206', '02'),
('020603', 'Amashca', '0206', '02'),
('020604', 'Anta', '0206', '02'),
('020605', 'Ataquero', '0206', '02'),
('020606', 'Marcara', '0206', '02'),
('020607', 'Pariahuanca', '0206', '02'),
('020608', 'San Miguel de Aco', '0206', '02'),
('020609', 'Shilla', '0206', '02'),
('020610', 'Tinco', '0206', '02'),
('020611', 'Yungar', '0206', '02'),
('020701', 'San Luis', '0207', '02'),
('020702', 'San Nicolás', '0207', '02'),
('020703', 'Yauya', '0207', '02'),
('020801', 'Casma', '0208', '02'),
('020802', 'Buena Vista Alta', '0208', '02'),
('020803', 'Comandante Noel', '0208', '02'),
('020804', 'Yautan', '0208', '02'),
('020901', 'Corongo', '0209', '02'),
('020902', 'Aco', '0209', '02'),
('020903', 'Bambas', '0209', '02'),
('020904', 'Cusca', '0209', '02'),
('020905', 'La Pampa', '0209', '02'),
('020906', 'Yanac', '0209', '02'),
('020907', 'Yupan', '0209', '02'),
('021001', 'Huari', '0210', '02'),
('021002', 'Anra', '0210', '02'),
('021003', 'Cajay', '0210', '02'),
('021004', 'Chavin de Huantar', '0210', '02'),
('021005', 'Huacachi', '0210', '02'),
('021006', 'Huacchis', '0210', '02'),
('021007', 'Huachis', '0210', '02'),
('021008', 'Huantar', '0210', '02'),
('021009', 'Masin', '0210', '02'),
('021010', 'Paucas', '0210', '02'),
('021011', 'Ponto', '0210', '02'),
('021012', 'Rahuapampa', '0210', '02'),
('021013', 'Rapayan', '0210', '02'),
('021014', 'San Marcos', '0210', '02'),
('021015', 'San Pedro de Chana', '0210', '02'),
('021016', 'Uco', '0210', '02'),
('021101', 'Huarmey', '0211', '02'),
('021102', 'Cochapeti', '0211', '02'),
('021103', 'Culebras', '0211', '02'),
('021104', 'Huayan', '0211', '02'),
('021105', 'Malvas', '0211', '02'),
('021201', 'Caraz', '0212', '02'),
('021202', 'Huallanca', '0212', '02'),
('021203', 'Huata', '0212', '02'),
('021204', 'Huaylas', '0212', '02'),
('021205', 'Mato', '0212', '02'),
('021206', 'Pamparomas', '0212', '02'),
('021207', 'Pueblo Libre', '0212', '02'),
('021208', 'Santa Cruz', '0212', '02'),
('021209', 'Santo Toribio', '0212', '02'),
('021210', 'Yuracmarca', '0212', '02'),
('021301', 'Piscobamba', '0213', '02'),
('021302', 'Casca', '0213', '02'),
('021303', 'Eleazar Guzmán Barron', '0213', '02'),
('021304', 'Fidel Olivas Escudero', '0213', '02'),
('021305', 'Llama', '0213', '02'),
('021306', 'Llumpa', '0213', '02'),
('021307', 'Lucma', '0213', '02'),
('021308', 'Musga', '0213', '02'),
('021401', 'Ocros', '0214', '02'),
('021402', 'Acas', '0214', '02'),
('021403', 'Cajamarquilla', '0214', '02'),
('021404', 'Carhuapampa', '0214', '02'),
('021405', 'Cochas', '0214', '02'),
('021406', 'Congas', '0214', '02'),
('021407', 'Llipa', '0214', '02'),
('021408', 'San Cristóbal de Rajan', '0214', '02'),
('021409', 'San Pedro', '0214', '02'),
('021410', 'Santiago de Chilcas', '0214', '02'),
('021501', 'Cabana', '0215', '02'),
('021502', 'Bolognesi', '0215', '02'),
('021503', 'Conchucos', '0215', '02'),
('021504', 'Huacaschuque', '0215', '02'),
('021505', 'Huandoval', '0215', '02'),
('021506', 'Lacabamba', '0215', '02'),
('021507', 'Llapo', '0215', '02'),
('021508', 'Pallasca', '0215', '02'),
('021509', 'Pampas', '0215', '02'),
('021510', 'Santa Rosa', '0215', '02'),
('021511', 'Tauca', '0215', '02'),
('021601', 'Pomabamba', '0216', '02'),
('021602', 'Huayllan', '0216', '02'),
('021603', 'Parobamba', '0216', '02'),
('021604', 'Quinuabamba', '0216', '02'),
('021701', 'Recuay', '0217', '02'),
('021702', 'Catac', '0217', '02'),
('021703', 'Cotaparaco', '0217', '02'),
('021704', 'Huayllapampa', '0217', '02'),
('021705', 'Llacllin', '0217', '02'),
('021706', 'Marca', '0217', '02'),
('021707', 'Pampas Chico', '0217', '02'),
('021708', 'Pararin', '0217', '02'),
('021709', 'Tapacocha', '0217', '02'),
('021710', 'Ticapampa', '0217', '02'),
('021801', 'Chimbote', '0218', '02'),
('021802', 'Cáceres del Perú', '0218', '02'),
('021803', 'Coishco', '0218', '02'),
('021804', 'Macate', '0218', '02'),
('021805', 'Moro', '0218', '02'),
('021806', 'Nepeña', '0218', '02'),
('021807', 'Samanco', '0218', '02'),
('021808', 'Santa', '0218', '02'),
('021809', 'Nuevo Chimbote', '0218', '02'),
('021901', 'Sihuas', '0219', '02'),
('021902', 'Acobamba', '0219', '02'),
('021903', 'Alfonso Ugarte', '0219', '02'),
('021904', 'Cashapampa', '0219', '02'),
('021905', 'Chingalpo', '0219', '02'),
('021906', 'Huayllabamba', '0219', '02'),
('021907', 'Quiches', '0219', '02'),
('021908', 'Ragash', '0219', '02'),
('021909', 'San Juan', '0219', '02'),
('021910', 'Sicsibamba', '0219', '02'),
('022001', 'Yungay', '0220', '02'),
('022002', 'Cascapara', '0220', '02'),
('022003', 'Mancos', '0220', '02'),
('022004', 'Matacoto', '0220', '02'),
('022005', 'Quillo', '0220', '02'),
('022006', 'Ranrahirca', '0220', '02'),
('022007', 'Shupluy', '0220', '02'),
('022008', 'Yanama', '0220', '02'),
('030101', 'Abancay', '0301', '03'),
('030102', 'Chacoche', '0301', '03'),
('030103', 'Circa', '0301', '03'),
('030104', 'Curahuasi', '0301', '03'),
('030105', 'Huanipaca', '0301', '03'),
('030106', 'Lambrama', '0301', '03'),
('030107', 'Pichirhua', '0301', '03'),
('030108', 'San Pedro de Cachora', '0301', '03'),
('030109', 'Tamburco', '0301', '03'),
('030201', 'Andahuaylas', '0302', '03'),
('030202', 'Andarapa', '0302', '03'),
('030203', 'Chiara', '0302', '03'),
('030204', 'Huancarama', '0302', '03'),
('030205', 'Huancaray', '0302', '03'),
('030206', 'Huayana', '0302', '03'),
('030207', 'Kishuara', '0302', '03'),
('030208', 'Pacobamba', '0302', '03'),
('030209', 'Pacucha', '0302', '03'),
('030210', 'Pampachiri', '0302', '03'),
('030211', 'Pomacocha', '0302', '03'),
('030212', 'San Antonio de Cachi', '0302', '03'),
('030213', 'San Jerónimo', '0302', '03'),
('030214', 'San Miguel de Chaccrampa', '0302', '03'),
('030215', 'Santa María de Chicmo', '0302', '03'),
('030216', 'Talavera', '0302', '03'),
('030217', 'Tumay Huaraca', '0302', '03'),
('030218', 'Turpo', '0302', '03'),
('030219', 'Kaquiabamba', '0302', '03'),
('030220', 'José María Arguedas', '0302', '03'),
('030301', 'Antabamba', '0303', '03'),
('030302', 'El Oro', '0303', '03'),
('030303', 'Huaquirca', '0303', '03'),
('030304', 'Juan Espinoza Medrano', '0303', '03'),
('030305', 'Oropesa', '0303', '03'),
('030306', 'Pachaconas', '0303', '03'),
('030307', 'Sabaino', '0303', '03'),
('030401', 'Chalhuanca', '0304', '03'),
('030402', 'Capaya', '0304', '03'),
('030403', 'Caraybamba', '0304', '03'),
('030404', 'Chapimarca', '0304', '03'),
('030405', 'Colcabamba', '0304', '03'),
('030406', 'Cotaruse', '0304', '03'),
('030407', 'Ihuayllo', '0304', '03'),
('030408', 'Justo Apu Sahuaraura', '0304', '03'),
('030409', 'Lucre', '0304', '03'),
('030410', 'Pocohuanca', '0304', '03'),
('030411', 'San Juan de Chacña', '0304', '03'),
('030412', 'Sañayca', '0304', '03'),
('030413', 'Soraya', '0304', '03'),
('030414', 'Tapairihua', '0304', '03'),
('030415', 'Tintay', '0304', '03'),
('030416', 'Toraya', '0304', '03'),
('030417', 'Yanaca', '0304', '03'),
('030501', 'Tambobamba', '0305', '03'),
('030502', 'Cotabambas', '0305', '03'),
('030503', 'Coyllurqui', '0305', '03'),
('030504', 'Haquira', '0305', '03'),
('030505', 'Mara', '0305', '03'),
('030506', 'Challhuahuacho', '0305', '03'),
('030601', 'Chincheros', '0306', '03'),
('030602', 'Anco_Huallo', '0306', '03'),
('030603', 'Cocharcas', '0306', '03'),
('030604', 'Huaccana', '0306', '03'),
('030605', 'Ocobamba', '0306', '03'),
('030606', 'Ongoy', '0306', '03'),
('030607', 'Uranmarca', '0306', '03'),
('030608', 'Ranracancha', '0306', '03'),
('030609', 'Rocchacc', '0306', '03'),
('030610', 'El Porvenir', '0306', '03'),
('030611', 'Los Chankas', '0306', '03'),
('030701', 'Chuquibambilla', '0307', '03'),
('030702', 'Curpahuasi', '0307', '03'),
('030703', 'Gamarra', '0307', '03'),
('030704', 'Huayllati', '0307', '03'),
('030705', 'Mamara', '0307', '03'),
('030706', 'Micaela Bastidas', '0307', '03'),
('030707', 'Pataypampa', '0307', '03'),
('030708', 'Progreso', '0307', '03'),
('030709', 'San Antonio', '0307', '03'),
('030710', 'Santa Rosa', '0307', '03'),
('030711', 'Turpay', '0307', '03'),
('030712', 'Vilcabamba', '0307', '03'),
('030713', 'Virundo', '0307', '03'),
('030714', 'Curasco', '0307', '03'),
('040101', 'Arequipa', '0401', '04'),
('040102', 'Alto Selva Alegre', '0401', '04'),
('040103', 'Cayma', '0401', '04'),
('040104', 'Cerro Colorado', '0401', '04'),
('040105', 'Characato', '0401', '04'),
('040106', 'Chiguata', '0401', '04'),
('040107', 'Jacobo Hunter', '0401', '04'),
('040108', 'La Joya', '0401', '04'),
('040109', 'Mariano Melgar', '0401', '04'),
('040110', 'Miraflores', '0401', '04'),
('040111', 'Mollebaya', '0401', '04'),
('040112', 'Paucarpata', '0401', '04'),
('040113', 'Pocsi', '0401', '04'),
('040114', 'Polobaya', '0401', '04'),
('040115', 'Quequeña', '0401', '04'),
('040116', 'Sabandia', '0401', '04'),
('040117', 'Sachaca', '0401', '04'),
('040118', 'San Juan de Siguas', '0401', '04'),
('040119', 'San Juan de Tarucani', '0401', '04'),
('040120', 'Santa Isabel de Siguas', '0401', '04'),
('040121', 'Santa Rita de Siguas', '0401', '04'),
('040122', 'Socabaya', '0401', '04'),
('040123', 'Tiabaya', '0401', '04'),
('040124', 'Uchumayo', '0401', '04'),
('040125', 'Vitor', '0401', '04'),
('040126', 'Yanahuara', '0401', '04'),
('040127', 'Yarabamba', '0401', '04'),
('040128', 'Yura', '0401', '04'),
('040129', 'José Luis Bustamante Y Rivero', '0401', '04'),
('040201', 'Camaná', '0402', '04'),
('040202', 'José María Quimper', '0402', '04'),
('040203', 'Mariano Nicolás Valcárcel', '0402', '04'),
('040204', 'Mariscal Cáceres', '0402', '04'),
('040205', 'Nicolás de Pierola', '0402', '04'),
('040206', 'Ocoña', '0402', '04'),
('040207', 'Quilca', '0402', '04'),
('040208', 'Samuel Pastor', '0402', '04'),
('040301', 'Caravelí', '0403', '04'),
('040302', 'Acarí', '0403', '04'),
('040303', 'Atico', '0403', '04'),
('040304', 'Atiquipa', '0403', '04'),
('040305', 'Bella Unión', '0403', '04'),
('040306', 'Cahuacho', '0403', '04'),
('040307', 'Chala', '0403', '04'),
('040308', 'Chaparra', '0403', '04'),
('040309', 'Huanuhuanu', '0403', '04'),
('040310', 'Jaqui', '0403', '04'),
('040311', 'Lomas', '0403', '04'),
('040312', 'Quicacha', '0403', '04'),
('040313', 'Yauca', '0403', '04'),
('040401', 'Aplao', '0404', '04'),
('040402', 'Andagua', '0404', '04'),
('040403', 'Ayo', '0404', '04'),
('040404', 'Chachas', '0404', '04'),
('040405', 'Chilcaymarca', '0404', '04'),
('040406', 'Choco', '0404', '04'),
('040407', 'Huancarqui', '0404', '04'),
('040408', 'Machaguay', '0404', '04'),
('040409', 'Orcopampa', '0404', '04'),
('040410', 'Pampacolca', '0404', '04'),
('040411', 'Tipan', '0404', '04'),
('040412', 'Uñon', '0404', '04'),
('040413', 'Uraca', '0404', '04'),
('040414', 'Viraco', '0404', '04'),
('040501', 'Chivay', '0405', '04'),
('040502', 'Achoma', '0405', '04'),
('040503', 'Cabanaconde', '0405', '04'),
('040504', 'Callalli', '0405', '04'),
('040505', 'Caylloma', '0405', '04'),
('040506', 'Coporaque', '0405', '04'),
('040507', 'Huambo', '0405', '04'),
('040508', 'Huanca', '0405', '04'),
('040509', 'Ichupampa', '0405', '04'),
('040510', 'Lari', '0405', '04'),
('040511', 'Lluta', '0405', '04'),
('040512', 'Maca', '0405', '04'),
('040513', 'Madrigal', '0405', '04'),
('040514', 'San Antonio de Chuca', '0405', '04'),
('040515', 'Sibayo', '0405', '04'),
('040516', 'Tapay', '0405', '04'),
('040517', 'Tisco', '0405', '04'),
('040518', 'Tuti', '0405', '04'),
('040519', 'Yanque', '0405', '04'),
('040520', 'Majes', '0405', '04'),
('040601', 'Chuquibamba', '0406', '04'),
('040602', 'Andaray', '0406', '04'),
('040603', 'Cayarani', '0406', '04'),
('040604', 'Chichas', '0406', '04'),
('040605', 'Iray', '0406', '04'),
('040606', 'Río Grande', '0406', '04'),
('040607', 'Salamanca', '0406', '04'),
('040608', 'Yanaquihua', '0406', '04'),
('040701', 'Mollendo', '0407', '04'),
('040702', 'Cocachacra', '0407', '04'),
('040703', 'Dean Valdivia', '0407', '04'),
('040704', 'Islay', '0407', '04'),
('040705', 'Mejia', '0407', '04'),
('040706', 'Punta de Bombón', '0407', '04'),
('040801', 'Cotahuasi', '0408', '04'),
('040802', 'Alca', '0408', '04'),
('040803', 'Charcana', '0408', '04'),
('040804', 'Huaynacotas', '0408', '04'),
('040805', 'Pampamarca', '0408', '04'),
('040806', 'Puyca', '0408', '04'),
('040807', 'Quechualla', '0408', '04'),
('040808', 'Sayla', '0408', '04'),
('040809', 'Tauria', '0408', '04'),
('040810', 'Tomepampa', '0408', '04'),
('040811', 'Toro', '0408', '04'),
('050101', 'Ayacucho', '0501', '05'),
('050102', 'Acocro', '0501', '05'),
('050103', 'Acos Vinchos', '0501', '05'),
('050104', 'Carmen Alto', '0501', '05'),
('050105', 'Chiara', '0501', '05'),
('050106', 'Ocros', '0501', '05'),
('050107', 'Pacaycasa', '0501', '05'),
('050108', 'Quinua', '0501', '05'),
('050109', 'San José de Ticllas', '0501', '05'),
('050110', 'San Juan Bautista', '0501', '05'),
('050111', 'Santiago de Pischa', '0501', '05'),
('050112', 'Socos', '0501', '05'),
('050113', 'Tambillo', '0501', '05'),
('050114', 'Vinchos', '0501', '05'),
('050115', 'Jesús Nazareno', '0501', '05'),
('050116', 'Andrés Avelino Cáceres Dorregaray', '0501', '05'),
('050201', 'Cangallo', '0502', '05'),
('050202', 'Chuschi', '0502', '05'),
('050203', 'Los Morochucos', '0502', '05'),
('050204', 'María Parado de Bellido', '0502', '05'),
('050205', 'Paras', '0502', '05'),
('050206', 'Totos', '0502', '05'),
('050301', 'Sancos', '0503', '05'),
('050302', 'Carapo', '0503', '05'),
('050303', 'Sacsamarca', '0503', '05'),
('050304', 'Santiago de Lucanamarca', '0503', '05'),
('050401', 'Huanta', '0504', '05'),
('050402', 'Ayahuanco', '0504', '05'),
('050403', 'Huamanguilla', '0504', '05'),
('050404', 'Iguain', '0504', '05'),
('050405', 'Luricocha', '0504', '05'),
('050406', 'Santillana', '0504', '05'),
('050407', 'Sivia', '0504', '05'),
('050408', 'Llochegua', '0504', '05'),
('050409', 'Canayre', '0504', '05'),
('050410', 'Uchuraccay', '0504', '05'),
('050411', 'Pucacolpa', '0504', '05'),
('050412', 'Chaca', '0504', '05'),
('050501', 'San Miguel', '0505', '05'),
('050502', 'Anco', '0505', '05'),
('050503', 'Ayna', '0505', '05'),
('050504', 'Chilcas', '0505', '05'),
('050505', 'Chungui', '0505', '05'),
('050506', 'Luis Carranza', '0505', '05'),
('050507', 'Santa Rosa', '0505', '05'),
('050508', 'Tambo', '0505', '05'),
('050509', 'Samugari', '0505', '05'),
('050510', 'Anchihuay', '0505', '05'),
('050511', 'Oronccoy', '0505', '05'),
('050601', 'Puquio', '0506', '05'),
('050602', 'Aucara', '0506', '05'),
('050603', 'Cabana', '0506', '05'),
('050604', 'Carmen Salcedo', '0506', '05'),
('050605', 'Chaviña', '0506', '05'),
('050606', 'Chipao', '0506', '05'),
('050607', 'Huac-Huas', '0506', '05'),
('050608', 'Laramate', '0506', '05'),
('050609', 'Leoncio Prado', '0506', '05'),
('050610', 'Llauta', '0506', '05'),
('050611', 'Lucanas', '0506', '05'),
('050612', 'Ocaña', '0506', '05'),
('050613', 'Otoca', '0506', '05'),
('050614', 'Saisa', '0506', '05'),
('050615', 'San Cristóbal', '0506', '05'),
('050616', 'San Juan', '0506', '05'),
('050617', 'San Pedro', '0506', '05'),
('050618', 'San Pedro de Palco', '0506', '05'),
('050619', 'Sancos', '0506', '05'),
('050620', 'Santa Ana de Huaycahuacho', '0506', '05'),
('050621', 'Santa Lucia', '0506', '05'),
('050701', 'Coracora', '0507', '05'),
('050702', 'Chumpi', '0507', '05'),
('050703', 'Coronel Castañeda', '0507', '05'),
('050704', 'Pacapausa', '0507', '05'),
('050705', 'Pullo', '0507', '05'),
('050706', 'Puyusca', '0507', '05'),
('050707', 'San Francisco de Ravacayco', '0507', '05'),
('050708', 'Upahuacho', '0507', '05'),
('050801', 'Pausa', '0508', '05'),
('050802', 'Colta', '0508', '05'),
('050803', 'Corculla', '0508', '05'),
('050804', 'Lampa', '0508', '05'),
('050805', 'Marcabamba', '0508', '05'),
('050806', 'Oyolo', '0508', '05'),
('050807', 'Pararca', '0508', '05'),
('050808', 'San Javier de Alpabamba', '0508', '05'),
('050809', 'San José de Ushua', '0508', '05'),
('050810', 'Sara Sara', '0508', '05'),
('050901', 'Querobamba', '0509', '05'),
('050902', 'Belén', '0509', '05'),
('050903', 'Chalcos', '0509', '05'),
('050904', 'Chilcayoc', '0509', '05'),
('050905', 'Huacaña', '0509', '05'),
('050906', 'Morcolla', '0509', '05'),
('050907', 'Paico', '0509', '05'),
('050908', 'San Pedro de Larcay', '0509', '05'),
('050909', 'San Salvador de Quije', '0509', '05'),
('050910', 'Santiago de Paucaray', '0509', '05'),
('050911', 'Soras', '0509', '05'),
('051001', 'Huancapi', '0510', '05'),
('051002', 'Alcamenca', '0510', '05'),
('051003', 'Apongo', '0510', '05'),
('051004', 'Asquipata', '0510', '05'),
('051005', 'Canaria', '0510', '05'),
('051006', 'Cayara', '0510', '05'),
('051007', 'Colca', '0510', '05'),
('051008', 'Huamanquiquia', '0510', '05'),
('051009', 'Huancaraylla', '0510', '05'),
('051010', 'Hualla', '0510', '05'),
('051011', 'Sarhua', '0510', '05'),
('051012', 'Vilcanchos', '0510', '05'),
('051101', 'Vilcas Huaman', '0511', '05'),
('051102', 'Accomarca', '0511', '05'),
('051103', 'Carhuanca', '0511', '05'),
('051104', 'Concepción', '0511', '05'),
('051105', 'Huambalpa', '0511', '05'),
('051106', 'Independencia', '0511', '05'),
('051107', 'Saurama', '0511', '05'),
('051108', 'Vischongo', '0511', '05'),
('060101', 'Cajamarca', '0601', '06'),
('060102', 'Asunción', '0601', '06'),
('060103', 'Chetilla', '0601', '06'),
('060104', 'Cospan', '0601', '06'),
('060105', 'Encañada', '0601', '06'),
('060106', 'Jesús', '0601', '06'),
('060107', 'Llacanora', '0601', '06'),
('060108', 'Los Baños del Inca', '0601', '06'),
('060109', 'Magdalena', '0601', '06'),
('060110', 'Matara', '0601', '06'),
('060111', 'Namora', '0601', '06'),
('060112', 'San Juan', '0601', '06'),
('060201', 'Cajabamba', '0602', '06'),
('060202', 'Cachachi', '0602', '06'),
('060203', 'Condebamba', '0602', '06'),
('060204', 'Sitacocha', '0602', '06'),
('060301', 'Celendín', '0603', '06'),
('060302', 'Chumuch', '0603', '06'),
('060303', 'Cortegana', '0603', '06'),
('060304', 'Huasmin', '0603', '06'),
('060305', 'Jorge Chávez', '0603', '06'),
('060306', 'José Gálvez', '0603', '06'),
('060307', 'Miguel Iglesias', '0603', '06'),
('060308', 'Oxamarca', '0603', '06'),
('060309', 'Sorochuco', '0603', '06'),
('060310', 'Sucre', '0603', '06'),
('060311', 'Utco', '0603', '06'),
('060312', 'La Libertad de Pallan', '0603', '06'),
('060401', 'Chota', '0604', '06'),
('060402', 'Anguia', '0604', '06'),
('060403', 'Chadin', '0604', '06'),
('060404', 'Chiguirip', '0604', '06'),
('060405', 'Chimban', '0604', '06'),
('060406', 'Choropampa', '0604', '06'),
('060407', 'Cochabamba', '0604', '06'),
('060408', 'Conchan', '0604', '06'),
('060409', 'Huambos', '0604', '06'),
('060410', 'Lajas', '0604', '06'),
('060411', 'Llama', '0604', '06'),
('060412', 'Miracosta', '0604', '06'),
('060413', 'Paccha', '0604', '06'),
('060414', 'Pion', '0604', '06'),
('060415', 'Querocoto', '0604', '06'),
('060416', 'San Juan de Licupis', '0604', '06'),
('060417', 'Tacabamba', '0604', '06'),
('060418', 'Tocmoche', '0604', '06'),
('060419', 'Chalamarca', '0604', '06'),
('060501', 'Contumaza', '0605', '06'),
('060502', 'Chilete', '0605', '06'),
('060503', 'Cupisnique', '0605', '06'),
('060504', 'Guzmango', '0605', '06'),
('060505', 'San Benito', '0605', '06'),
('060506', 'Santa Cruz de Toledo', '0605', '06'),
('060507', 'Tantarica', '0605', '06'),
('060508', 'Yonan', '0605', '06'),
('060601', 'Cutervo', '0606', '06'),
('060602', 'Callayuc', '0606', '06'),
('060603', 'Choros', '0606', '06'),
('060604', 'Cujillo', '0606', '06'),
('060605', 'La Ramada', '0606', '06'),
('060606', 'Pimpingos', '0606', '06'),
('060607', 'Querocotillo', '0606', '06'),
('060608', 'San Andrés de Cutervo', '0606', '06'),
('060609', 'San Juan de Cutervo', '0606', '06'),
('060610', 'San Luis de Lucma', '0606', '06'),
('060611', 'Santa Cruz', '0606', '06'),
('060612', 'Santo Domingo de la Capilla', '0606', '06'),
('060613', 'Santo Tomas', '0606', '06'),
('060614', 'Socota', '0606', '06'),
('060615', 'Toribio Casanova', '0606', '06'),
('060701', 'Bambamarca', '0607', '06'),
('060702', 'Chugur', '0607', '06'),
('060703', 'Hualgayoc', '0607', '06'),
('060801', 'Jaén', '0608', '06'),
('060802', 'Bellavista', '0608', '06'),
('060803', 'Chontali', '0608', '06'),
('060804', 'Colasay', '0608', '06'),
('060805', 'Huabal', '0608', '06'),
('060806', 'Las Pirias', '0608', '06'),
('060807', 'Pomahuaca', '0608', '06'),
('060808', 'Pucara', '0608', '06'),
('060809', 'Sallique', '0608', '06'),
('060810', 'San Felipe', '0608', '06'),
('060811', 'San José del Alto', '0608', '06'),
('060812', 'Santa Rosa', '0608', '06'),
('060901', 'San Ignacio', '0609', '06'),
('060902', 'Chirinos', '0609', '06'),
('060903', 'Huarango', '0609', '06'),
('060904', 'La Coipa', '0609', '06'),
('060905', 'Namballe', '0609', '06'),
('060906', 'San José de Lourdes', '0609', '06'),
('060907', 'Tabaconas', '0609', '06'),
('061001', 'Pedro Gálvez', '0610', '06'),
('061002', 'Chancay', '0610', '06'),
('061003', 'Eduardo Villanueva', '0610', '06'),
('061004', 'Gregorio Pita', '0610', '06'),
('061005', 'Ichocan', '0610', '06'),
('061006', 'José Manuel Quiroz', '0610', '06'),
('061007', 'José Sabogal', '0610', '06'),
('061101', 'San Miguel', '0611', '06'),
('061102', 'Bolívar', '0611', '06'),
('061103', 'Calquis', '0611', '06'),
('061104', 'Catilluc', '0611', '06'),
('061105', 'El Prado', '0611', '06'),
('061106', 'La Florida', '0611', '06'),
('061107', 'Llapa', '0611', '06'),
('061108', 'Nanchoc', '0611', '06'),
('061109', 'Niepos', '0611', '06'),
('061110', 'San Gregorio', '0611', '06'),
('061111', 'San Silvestre de Cochan', '0611', '06'),
('061112', 'Tongod', '0611', '06'),
('061113', 'Unión Agua Blanca', '0611', '06'),
('061201', 'San Pablo', '0612', '06'),
('061202', 'San Bernardino', '0612', '06'),
('061203', 'San Luis', '0612', '06'),
('061204', 'Tumbaden', '0612', '06'),
('061301', 'Santa Cruz', '0613', '06'),
('061302', 'Andabamba', '0613', '06'),
('061303', 'Catache', '0613', '06'),
('061304', 'Chancaybaños', '0613', '06'),
('061305', 'La Esperanza', '0613', '06'),
('061306', 'Ninabamba', '0613', '06'),
('061307', 'Pulan', '0613', '06'),
('061308', 'Saucepampa', '0613', '06'),
('061309', 'Sexi', '0613', '06'),
('061310', 'Uticyacu', '0613', '06'),
('061311', 'Yauyucan', '0613', '06'),
('070101', 'Callao', '0701', '07'),
('070102', 'Bellavista', '0701', '07'),
('070103', 'Carmen de la Legua Reynoso', '0701', '07'),
('070104', 'La Perla', '0701', '07'),
('070105', 'La Punta', '0701', '07'),
('070106', 'Ventanilla', '0701', '07'),
('070107', 'Mi Perú', '0701', '07'),
('080101', 'Cusco', '0801', '08'),
('080102', 'Ccorca', '0801', '08'),
('080103', 'Poroy', '0801', '08'),
('080104', 'San Jerónimo', '0801', '08'),
('080105', 'San Sebastian', '0801', '08'),
('080106', 'Santiago', '0801', '08'),
('080107', 'Saylla', '0801', '08'),
('080108', 'Wanchaq', '0801', '08'),
('080201', 'Acomayo', '0802', '08'),
('080202', 'Acopia', '0802', '08'),
('080203', 'Acos', '0802', '08'),
('080204', 'Mosoc Llacta', '0802', '08'),
('080205', 'Pomacanchi', '0802', '08'),
('080206', 'Rondocan', '0802', '08'),
('080207', 'Sangarara', '0802', '08'),
('080301', 'Anta', '0803', '08'),
('080302', 'Ancahuasi', '0803', '08'),
('080303', 'Cachimayo', '0803', '08'),
('080304', 'Chinchaypujio', '0803', '08'),
('080305', 'Huarocondo', '0803', '08'),
('080306', 'Limatambo', '0803', '08'),
('080307', 'Mollepata', '0803', '08'),
('080308', 'Pucyura', '0803', '08'),
('080309', 'Zurite', '0803', '08'),
('080401', 'Calca', '0804', '08'),
('080402', 'Coya', '0804', '08'),
('080403', 'Lamay', '0804', '08'),
('080404', 'Lares', '0804', '08'),
('080405', 'Pisac', '0804', '08'),
('080406', 'San Salvador', '0804', '08'),
('080407', 'Taray', '0804', '08'),
('080408', 'Yanatile', '0804', '08'),
('080501', 'Yanaoca', '0805', '08'),
('080502', 'Checca', '0805', '08'),
('080503', 'Kunturkanki', '0805', '08'),
('080504', 'Langui', '0805', '08'),
('080505', 'Layo', '0805', '08'),
('080506', 'Pampamarca', '0805', '08'),
('080507', 'Quehue', '0805', '08'),
('080508', 'Tupac Amaru', '0805', '08'),
('080601', 'Sicuani', '0806', '08'),
('080602', 'Checacupe', '0806', '08'),
('080603', 'Combapata', '0806', '08'),
('080604', 'Marangani', '0806', '08'),
('080605', 'Pitumarca', '0806', '08'),
('080606', 'San Pablo', '0806', '08'),
('080607', 'San Pedro', '0806', '08'),
('080608', 'Tinta', '0806', '08'),
('080701', 'Santo Tomas', '0807', '08'),
('080702', 'Capacmarca', '0807', '08'),
('080703', 'Chamaca', '0807', '08'),
('080704', 'Colquemarca', '0807', '08'),
('080705', 'Livitaca', '0807', '08'),
('080706', 'Llusco', '0807', '08'),
('080707', 'Quiñota', '0807', '08'),
('080708', 'Velille', '0807', '08'),
('080801', 'Espinar', '0808', '08'),
('080802', 'Condoroma', '0808', '08'),
('080803', 'Coporaque', '0808', '08'),
('080804', 'Ocoruro', '0808', '08'),
('080805', 'Pallpata', '0808', '08'),
('080806', 'Pichigua', '0808', '08'),
('080807', 'Suyckutambo', '0808', '08'),
('080808', 'Alto Pichigua', '0808', '08'),
('080901', 'Santa Ana', '0809', '08'),
('080902', 'Echarate', '0809', '08'),
('080903', 'Huayopata', '0809', '08'),
('080904', 'Maranura', '0809', '08'),
('080905', 'Ocobamba', '0809', '08'),
('080906', 'Quellouno', '0809', '08'),
('080907', 'Kimbiri', '0809', '08'),
('080908', 'Santa Teresa', '0809', '08'),
('080909', 'Vilcabamba', '0809', '08'),
('080910', 'Pichari', '0809', '08'),
('080911', 'Inkawasi', '0809', '08'),
('080912', 'Villa Virgen', '0809', '08'),
('080913', 'Villa Kintiarina', '0809', '08'),
('080914', 'Megantoni', '0809', '08'),
('081001', 'Paruro', '0810', '08'),
('081002', 'Accha', '0810', '08'),
('081003', 'Ccapi', '0810', '08'),
('081004', 'Colcha', '0810', '08'),
('081005', 'Huanoquite', '0810', '08'),
('081006', 'Omachaç', '0810', '08'),
('081007', 'Paccaritambo', '0810', '08'),
('081008', 'Pillpinto', '0810', '08'),
('081009', 'Yaurisque', '0810', '08'),
('081101', 'Paucartambo', '0811', '08'),
('081102', 'Caicay', '0811', '08'),
('081103', 'Challabamba', '0811', '08'),
('081104', 'Colquepata', '0811', '08'),
('081105', 'Huancarani', '0811', '08'),
('081106', 'Kosñipata', '0811', '08'),
('081201', 'Urcos', '0812', '08'),
('081202', 'Andahuaylillas', '0812', '08'),
('081203', 'Camanti', '0812', '08'),
('081204', 'Ccarhuayo', '0812', '08'),
('081205', 'Ccatca', '0812', '08'),
('081206', 'Cusipata', '0812', '08'),
('081207', 'Huaro', '0812', '08'),
('081208', 'Lucre', '0812', '08'),
('081209', 'Marcapata', '0812', '08'),
('081210', 'Ocongate', '0812', '08'),
('081211', 'Oropesa', '0812', '08'),
('081212', 'Quiquijana', '0812', '08'),
('081301', 'Urubamba', '0813', '08'),
('081302', 'Chinchero', '0813', '08'),
('081303', 'Huayllabamba', '0813', '08'),
('081304', 'Machupicchu', '0813', '08'),
('081305', 'Maras', '0813', '08'),
('081306', 'Ollantaytambo', '0813', '08'),
('081307', 'Yucay', '0813', '08'),
('090101', 'Huancavelica', '0901', '09'),
('090102', 'Acobambilla', '0901', '09'),
('090103', 'Acoria', '0901', '09'),
('090104', 'Conayca', '0901', '09'),
('090105', 'Cuenca', '0901', '09'),
('090106', 'Huachocolpa', '0901', '09'),
('090107', 'Huayllahuara', '0901', '09'),
('090108', 'Izcuchaca', '0901', '09'),
('090109', 'Laria', '0901', '09'),
('090110', 'Manta', '0901', '09'),
('090111', 'Mariscal Cáceres', '0901', '09'),
('090112', 'Moya', '0901', '09'),
('090113', 'Nuevo Occoro', '0901', '09'),
('090114', 'Palca', '0901', '09'),
('090115', 'Pilchaca', '0901', '09'),
('090116', 'Vilca', '0901', '09'),
('090117', 'Yauli', '0901', '09'),
('090118', 'Ascensión', '0901', '09'),
('090119', 'Huando', '0901', '09'),
('090201', 'Acobamba', '0902', '09'),
('090202', 'Andabamba', '0902', '09'),
('090203', 'Anta', '0902', '09'),
('090204', 'Caja', '0902', '09'),
('090205', 'Marcas', '0902', '09'),
('090206', 'Paucara', '0902', '09'),
('090207', 'Pomacocha', '0902', '09'),
('090208', 'Rosario', '0902', '09'),
('090301', 'Lircay', '0903', '09'),
('090302', 'Anchonga', '0903', '09'),
('090303', 'Callanmarca', '0903', '09'),
('090304', 'Ccochaccasa', '0903', '09'),
('090305', 'Chincho', '0903', '09'),
('090306', 'Congalla', '0903', '09'),
('090307', 'Huanca-Huanca', '0903', '09'),
('090308', 'Huayllay Grande', '0903', '09'),
('090309', 'Julcamarca', '0903', '09'),
('090310', 'San Antonio de Antaparco', '0903', '09'),
('090311', 'Santo Tomas de Pata', '0903', '09'),
('090312', 'Secclla', '0903', '09'),
('090401', 'Castrovirreyna', '0904', '09'),
('090402', 'Arma', '0904', '09'),
('090403', 'Aurahua', '0904', '09'),
('090404', 'Capillas', '0904', '09'),
('090405', 'Chupamarca', '0904', '09'),
('090406', 'Cocas', '0904', '09'),
('090407', 'Huachos', '0904', '09'),
('090408', 'Huamatambo', '0904', '09'),
('090409', 'Mollepampa', '0904', '09'),
('090410', 'San Juan', '0904', '09'),
('090411', 'Santa Ana', '0904', '09'),
('090412', 'Tantara', '0904', '09'),
('090413', 'Ticrapo', '0904', '09'),
('090501', 'Churcampa', '0905', '09'),
('090502', 'Anco', '0905', '09'),
('090503', 'Chinchihuasi', '0905', '09'),
('090504', 'El Carmen', '0905', '09'),
('090505', 'La Merced', '0905', '09'),
('090506', 'Locroja', '0905', '09'),
('090507', 'Paucarbamba', '0905', '09'),
('090508', 'San Miguel de Mayocc', '0905', '09'),
('090509', 'San Pedro de Coris', '0905', '09'),
('090510', 'Pachamarca', '0905', '09'),
('090511', 'Cosme', '0905', '09'),
('090601', 'Huaytara', '0906', '09'),
('090602', 'Ayavi', '0906', '09'),
('090603', 'Córdova', '0906', '09'),
('090604', 'Huayacundo Arma', '0906', '09'),
('090605', 'Laramarca', '0906', '09'),
('090606', 'Ocoyo', '0906', '09'),
('090607', 'Pilpichaca', '0906', '09'),
('090608', 'Querco', '0906', '09'),
('090609', 'Quito-Arma', '0906', '09'),
('090610', 'San Antonio de Cusicancha', '0906', '09'),
('090611', 'San Francisco de Sangayaico', '0906', '09'),
('090612', 'San Isidro', '0906', '09'),
('090613', 'Santiago de Chocorvos', '0906', '09'),
('090614', 'Santiago de Quirahuara', '0906', '09'),
('090615', 'Santo Domingo de Capillas', '0906', '09'),
('090616', 'Tambo', '0906', '09'),
('090701', 'Pampas', '0907', '09'),
('090702', 'Acostambo', '0907', '09'),
('090703', 'Acraquia', '0907', '09'),
('090704', 'Ahuaycha', '0907', '09'),
('090705', 'Colcabamba', '0907', '09'),
('090706', 'Daniel Hernández', '0907', '09'),
('090707', 'Huachocolpa', '0907', '09'),
('090709', 'Huaribamba', '0907', '09'),
('090710', 'Ñahuimpuquio', '0907', '09'),
('090711', 'Pazos', '0907', '09'),
('090713', 'Quishuar', '0907', '09'),
('090714', 'Salcabamba', '0907', '09'),
('090715', 'Salcahuasi', '0907', '09'),
('090716', 'San Marcos de Rocchac', '0907', '09'),
('090717', 'Surcubamba', '0907', '09'),
('090718', 'Tintay Puncu', '0907', '09'),
('090719', 'Quichuas', '0907', '09'),
('090720', 'Andaymarca', '0907', '09'),
('090721', 'Roble', '0907', '09'),
('090722', 'Pichos', '0907', '09'),
('090723', 'Santiago de Tucuma', '0907', '09'),
('100101', 'Huanuco', '1001', '10'),
('100102', 'Amarilis', '1001', '10'),
('100103', 'Chinchao', '1001', '10'),
('100104', 'Churubamba', '1001', '10'),
('100105', 'Margos', '1001', '10'),
('100106', 'Quisqui (Kichki)', '1001', '10'),
('100107', 'San Francisco de Cayran', '1001', '10'),
('100108', 'San Pedro de Chaulan', '1001', '10'),
('100109', 'Santa María del Valle', '1001', '10'),
('100110', 'Yarumayo', '1001', '10'),
('100111', 'Pillco Marca', '1001', '10'),
('100112', 'Yacus', '1001', '10'),
('100113', 'San Pablo de Pillao', '1001', '10'),
('100201', 'Ambo', '1002', '10'),
('100202', 'Cayna', '1002', '10'),
('100203', 'Colpas', '1002', '10'),
('100204', 'Conchamarca', '1002', '10'),
('100205', 'Huacar', '1002', '10'),
('100206', 'San Francisco', '1002', '10'),
('100207', 'San Rafael', '1002', '10'),
('100208', 'Tomay Kichwa', '1002', '10'),
('100301', 'La Unión', '1003', '10'),
('100307', 'Chuquis', '1003', '10'),
('100311', 'Marías', '1003', '10'),
('100313', 'Pachas', '1003', '10'),
('100316', 'Quivilla', '1003', '10'),
('100317', 'Ripan', '1003', '10'),
('100321', 'Shunqui', '1003', '10'),
('100322', 'Sillapata', '1003', '10'),
('100323', 'Yanas', '1003', '10'),
('100401', 'Huacaybamba', '1004', '10'),
('100402', 'Canchabamba', '1004', '10'),
('100403', 'Cochabamba', '1004', '10'),
('100404', 'Pinra', '1004', '10'),
('100501', 'Llata', '1005', '10'),
('100502', 'Arancay', '1005', '10'),
('100503', 'Chavín de Pariarca', '1005', '10'),
('100504', 'Jacas Grande', '1005', '10'),
('100505', 'Jircan', '1005', '10'),
('100506', 'Miraflores', '1005', '10'),
('100507', 'Monzón', '1005', '10'),
('100508', 'Punchao', '1005', '10'),
('100509', 'Puños', '1005', '10'),
('100510', 'Singa', '1005', '10'),
('100511', 'Tantamayo', '1005', '10'),
('100601', 'Rupa-Rupa', '1006', '10'),
('100602', 'Daniel Alomía Robles', '1006', '10'),
('100603', 'Hermílio Valdizan', '1006', '10'),
('100604', 'José Crespo y Castillo', '1006', '10'),
('100605', 'Luyando', '1006', '10'),
('100606', 'Mariano Damaso Beraun', '1006', '10'),
('100607', 'Pucayacu', '1006', '10'),
('100608', 'Castillo Grande', '1006', '10'),
('100609', 'Pueblo Nuevo', '1006', '10'),
('100610', 'Santo Domingo de Anda', '1006', '10'),
('100701', 'Huacrachuco', '1007', '10'),
('100702', 'Cholon', '1007', '10'),
('100703', 'San Buenaventura', '1007', '10'),
('100704', 'La Morada', '1007', '10'),
('100705', 'Santa Rosa de Alto Yanajanca', '1007', '10'),
('100801', 'Panao', '1008', '10'),
('100802', 'Chaglla', '1008', '10'),
('100803', 'Molino', '1008', '10'),
('100804', 'Umari', '1008', '10'),
('100901', 'Puerto Inca', '1009', '10'),
('100902', 'Codo del Pozuzo', '1009', '10'),
('100903', 'Honoria', '1009', '10'),
('100904', 'Tournavista', '1009', '10'),
('100905', 'Yuyapichis', '1009', '10'),
('101001', 'Jesús', '1010', '10'),
('101002', 'Baños', '1010', '10'),
('101003', 'Jivia', '1010', '10'),
('101004', 'Queropalca', '1010', '10'),
('101005', 'Rondos', '1010', '10'),
('101006', 'San Francisco de Asís', '1010', '10'),
('101007', 'San Miguel de Cauri', '1010', '10'),
('101101', 'Chavinillo', '1011', '10'),
('101102', 'Cahuac', '1011', '10'),
('101103', 'Chacabamba', '1011', '10'),
('101104', 'Aparicio Pomares', '1011', '10'),
('101105', 'Jacas Chico', '1011', '10'),
('101106', 'Obas', '1011', '10'),
('101107', 'Pampamarca', '1011', '10'),
('101108', 'Choras', '1011', '10'),
('110101', 'Ica', '1101', '11'),
('110102', 'La Tinguiña', '1101', '11'),
('110103', 'Los Aquijes', '1101', '11'),
('110104', 'Ocucaje', '1101', '11'),
('110105', 'Pachacutec', '1101', '11'),
('110106', 'Parcona', '1101', '11'),
('110107', 'Pueblo Nuevo', '1101', '11'),
('110108', 'Salas', '1101', '11'),
('110109', 'San José de Los Molinos', '1101', '11'),
('110110', 'San Juan Bautista', '1101', '11'),
('110111', 'Santiago', '1101', '11'),
('110112', 'Subtanjalla', '1101', '11'),
('110113', 'Tate', '1101', '11'),
('110114', 'Yauca del Rosario', '1101', '11'),
('110201', 'Chincha Alta', '1102', '11'),
('110202', 'Alto Laran', '1102', '11'),
('110203', 'Chavin', '1102', '11'),
('110204', 'Chincha Baja', '1102', '11'),
('110205', 'El Carmen', '1102', '11'),
('110206', 'Grocio Prado', '1102', '11'),
('110207', 'Pueblo Nuevo', '1102', '11'),
('110208', 'San Juan de Yanac', '1102', '11'),
('110209', 'San Pedro de Huacarpana', '1102', '11'),
('110210', 'Sunampe', '1102', '11'),
('110211', 'Tambo de Mora', '1102', '11'),
('110301', 'Nasca', '1103', '11'),
('110302', 'Changuillo', '1103', '11'),
('110303', 'El Ingenio', '1103', '11'),
('110304', 'Marcona', '1103', '11'),
('110305', 'Vista Alegre', '1103', '11'),
('110401', 'Palpa', '1104', '11'),
('110402', 'Llipata', '1104', '11'),
('110403', 'Río Grande', '1104', '11'),
('110404', 'Santa Cruz', '1104', '11'),
('110405', 'Tibillo', '1104', '11'),
('110501', 'Pisco', '1105', '11'),
('110502', 'Huancano', '1105', '11'),
('110503', 'Humay', '1105', '11'),
('110504', 'Independencia', '1105', '11'),
('110505', 'Paracas', '1105', '11'),
('110506', 'San Andrés', '1105', '11'),
('110507', 'San Clemente', '1105', '11'),
('110508', 'Tupac Amaru Inca', '1105', '11'),
('120101', 'Huancayo', '1201', '12'),
('120104', 'Carhuacallanga', '1201', '12'),
('120105', 'Chacapampa', '1201', '12'),
('120106', 'Chicche', '1201', '12'),
('120107', 'Chilca', '1201', '12'),
('120108', 'Chongos Alto', '1201', '12'),
('120111', 'Chupuro', '1201', '12'),
('120112', 'Colca', '1201', '12'),
('120113', 'Cullhuas', '1201', '12'),
('120114', 'El Tambo', '1201', '12'),
('120116', 'Huacrapuquio', '1201', '12'),
('120117', 'Hualhuas', '1201', '12'),
('120119', 'Huancan', '1201', '12'),
('120120', 'Huasicancha', '1201', '12'),
('120121', 'Huayucachi', '1201', '12'),
('120122', 'Ingenio', '1201', '12'),
('120124', 'Pariahuanca', '1201', '12'),
('120125', 'Pilcomayo', '1201', '12'),
('120126', 'Pucara', '1201', '12'),
('120127', 'Quichuay', '1201', '12'),
('120128', 'Quilcas', '1201', '12'),
('120129', 'San Agustín', '1201', '12'),
('120130', 'San Jerónimo de Tunan', '1201', '12'),
('120132', 'Saño', '1201', '12'),
('120133', 'Sapallanga', '1201', '12'),
('120134', 'Sicaya', '1201', '12'),
('120135', 'Santo Domingo de Acobamba', '1201', '12'),
('120136', 'Viques', '1201', '12'),
('120201', 'Concepción', '1202', '12'),
('120202', 'Aco', '1202', '12'),
('120203', 'Andamarca', '1202', '12'),
('120204', 'Chambara', '1202', '12'),
('120205', 'Cochas', '1202', '12'),
('120206', 'Comas', '1202', '12'),
('120207', 'Heroínas Toledo', '1202', '12'),
('120208', 'Manzanares', '1202', '12'),
('120209', 'Mariscal Castilla', '1202', '12'),
('120210', 'Matahuasi', '1202', '12'),
('120211', 'Mito', '1202', '12'),
('120212', 'Nueve de Julio', '1202', '12'),
('120213', 'Orcotuna', '1202', '12'),
('120214', 'San José de Quero', '1202', '12'),
('120215', 'Santa Rosa de Ocopa', '1202', '12'),
('120301', 'Chanchamayo', '1203', '12'),
('120302', 'Perene', '1203', '12'),
('120303', 'Pichanaqui', '1203', '12'),
('120304', 'San Luis de Shuaro', '1203', '12'),
('120305', 'San Ramón', '1203', '12'),
('120306', 'Vitoc', '1203', '12'),
('120401', 'Jauja', '1204', '12'),
('120402', 'Acolla', '1204', '12'),
('120403', 'Apata', '1204', '12'),
('120404', 'Ataura', '1204', '12'),
('120405', 'Canchayllo', '1204', '12'),
('120406', 'Curicaca', '1204', '12'),
('120407', 'El Mantaro', '1204', '12'),
('120408', 'Huamali', '1204', '12'),
('120409', 'Huaripampa', '1204', '12'),
('120410', 'Huertas', '1204', '12'),
('120411', 'Janjaillo', '1204', '12'),
('120412', 'Julcán', '1204', '12'),
('120413', 'Leonor Ordóñez', '1204', '12'),
('120414', 'Llocllapampa', '1204', '12'),
('120415', 'Marco', '1204', '12'),
('120416', 'Masma', '1204', '12'),
('120417', 'Masma Chicche', '1204', '12'),
('120418', 'Molinos', '1204', '12'),
('120419', 'Monobamba', '1204', '12'),
('120420', 'Muqui', '1204', '12'),
('120421', 'Muquiyauyo', '1204', '12'),
('120422', 'Paca', '1204', '12'),
('120423', 'Paccha', '1204', '12'),
('120424', 'Pancan', '1204', '12'),
('120425', 'Parco', '1204', '12'),
('120426', 'Pomacancha', '1204', '12'),
('120427', 'Ricran', '1204', '12'),
('120428', 'San Lorenzo', '1204', '12'),
('120429', 'San Pedro de Chunan', '1204', '12'),
('120430', 'Sausa', '1204', '12'),
('120431', 'Sincos', '1204', '12'),
('120432', 'Tunan Marca', '1204', '12'),
('120433', 'Yauli', '1204', '12'),
('120434', 'Yauyos', '1204', '12'),
('120501', 'Junin', '1205', '12'),
('120502', 'Carhuamayo', '1205', '12'),
('120503', 'Ondores', '1205', '12'),
('120504', 'Ulcumayo', '1205', '12'),
('120601', 'Satipo', '1206', '12'),
('120602', 'Coviriali', '1206', '12'),
('120603', 'Llaylla', '1206', '12'),
('120604', 'Mazamari', '1206', '12'),
('120605', 'Pampa Hermosa', '1206', '12'),
('120606', 'Pangoa', '1206', '12'),
('120607', 'Río Negro', '1206', '12'),
('120608', 'Río Tambo', '1206', '12'),
('120609', 'Vizcatan del Ene', '1206', '12'),
('120701', 'Tarma', '1207', '12'),
('120702', 'Acobamba', '1207', '12'),
('120703', 'Huaricolca', '1207', '12'),
('120704', 'Huasahuasi', '1207', '12'),
('120705', 'La Unión', '1207', '12'),
('120706', 'Palca', '1207', '12'),
('120707', 'Palcamayo', '1207', '12'),
('120708', 'San Pedro de Cajas', '1207', '12'),
('120709', 'Tapo', '1207', '12'),
('120801', 'La Oroya', '1208', '12'),
('120802', 'Chacapalpa', '1208', '12'),
('120803', 'Huay-Huay', '1208', '12'),
('120804', 'Marcapomacocha', '1208', '12'),
('120805', 'Morococha', '1208', '12'),
('120806', 'Paccha', '1208', '12'),
('120807', 'Santa Bárbara de Carhuacayan', '1208', '12'),
('120808', 'Santa Rosa de Sacco', '1208', '12'),
('120809', 'Suitucancha', '1208', '12'),
('120810', 'Yauli', '1208', '12'),
('120901', 'Chupaca', '1209', '12'),
('120902', 'Ahuac', '1209', '12'),
('120903', 'Chongos Bajo', '1209', '12'),
('120904', 'Huachac', '1209', '12'),
('120905', 'Huamancaca Chico', '1209', '12'),
('120906', 'San Juan de Iscos', '1209', '12'),
('120907', 'San Juan de Jarpa', '1209', '12'),
('120908', 'Tres de Diciembre', '1209', '12'),
('120909', 'Yanacancha', '1209', '12'),
('130101', 'Trujillo', '1301', '13'),
('130102', 'El Porvenir', '1301', '13'),
('130103', 'Florencia de Mora', '1301', '13'),
('130104', 'Huanchaco', '1301', '13'),
('130105', 'La Esperanza', '1301', '13'),
('130106', 'Laredo', '1301', '13'),
('130107', 'Moche', '1301', '13'),
('130108', 'Poroto', '1301', '13'),
('130109', 'Salaverry', '1301', '13'),
('130110', 'Simbal', '1301', '13'),
('130111', 'Victor Larco Herrera', '1301', '13'),
('130201', 'Ascope', '1302', '13'),
('130202', 'Chicama', '1302', '13'),
('130203', 'Chocope', '1302', '13'),
('130204', 'Magdalena de Cao', '1302', '13'),
('130205', 'Paijan', '1302', '13'),
('130206', 'Rázuri', '1302', '13'),
('130207', 'Santiago de Cao', '1302', '13'),
('130208', 'Casa Grande', '1302', '13'),
('130301', 'Bolívar', '1303', '13'),
('130302', 'Bambamarca', '1303', '13'),
('130303', 'Condormarca', '1303', '13'),
('130304', 'Longotea', '1303', '13'),
('130305', 'Uchumarca', '1303', '13'),
('130306', 'Ucuncha', '1303', '13'),
('130401', 'Chepen', '1304', '13'),
('130402', 'Pacanga', '1304', '13'),
('130403', 'Pueblo Nuevo', '1304', '13'),
('130501', 'Julcan', '1305', '13'),
('130502', 'Calamarca', '1305', '13'),
('130503', 'Carabamba', '1305', '13'),
('130504', 'Huaso', '1305', '13'),
('130601', 'Otuzco', '1306', '13'),
('130602', 'Agallpampa', '1306', '13'),
('130604', 'Charat', '1306', '13'),
('130605', 'Huaranchal', '1306', '13'),
('130606', 'La Cuesta', '1306', '13'),
('130608', 'Mache', '1306', '13'),
('130610', 'Paranday', '1306', '13'),
('130611', 'Salpo', '1306', '13'),
('130613', 'Sinsicap', '1306', '13'),
('130614', 'Usquil', '1306', '13'),
('130701', 'San Pedro de Lloc', '1307', '13'),
('130702', 'Guadalupe', '1307', '13'),
('130703', 'Jequetepeque', '1307', '13'),
('130704', 'Pacasmayo', '1307', '13'),
('130705', 'San José', '1307', '13'),
('130801', 'Tayabamba', '1308', '13'),
('130802', 'Buldibuyo', '1308', '13'),
('130803', 'Chillia', '1308', '13'),
('130804', 'Huancaspata', '1308', '13'),
('130805', 'Huaylillas', '1308', '13'),
('130806', 'Huayo', '1308', '13'),
('130807', 'Ongon', '1308', '13'),
('130808', 'Parcoy', '1308', '13'),
('130809', 'Pataz', '1308', '13'),
('130810', 'Pias', '1308', '13'),
('130811', 'Santiago de Challas', '1308', '13'),
('130812', 'Taurija', '1308', '13'),
('130813', 'Urpay', '1308', '13'),
('130901', 'Huamachuco', '1309', '13'),
('130902', 'Chugay', '1309', '13'),
('130903', 'Cochorco', '1309', '13'),
('130904', 'Curgos', '1309', '13'),
('130905', 'Marcabal', '1309', '13'),
('130906', 'Sanagoran', '1309', '13'),
('130907', 'Sarin', '1309', '13'),
('130908', 'Sartimbamba', '1309', '13'),
('131001', 'Santiago de Chuco', '1310', '13'),
('131002', 'Angasmarca', '1310', '13'),
('131003', 'Cachicadan', '1310', '13'),
('131004', 'Mollebamba', '1310', '13'),
('131005', 'Mollepata', '1310', '13'),
('131006', 'Quiruvilca', '1310', '13'),
('131007', 'Santa Cruz de Chuca', '1310', '13'),
('131008', 'Sitabamba', '1310', '13'),
('131101', 'Cascas', '1311', '13'),
('131102', 'Lucma', '1311', '13'),
('131103', 'Marmot', '1311', '13'),
('131104', 'Sayapullo', '1311', '13'),
('131201', 'Viru', '1312', '13'),
('131202', 'Chao', '1312', '13'),
('131203', 'Guadalupito', '1312', '13'),
('140101', 'Chiclayo', '1401', '14'),
('140102', 'Chongoyape', '1401', '14'),
('140103', 'Eten', '1401', '14'),
('140104', 'Eten Puerto', '1401', '14'),
('140105', 'José Leonardo Ortiz', '1401', '14'),
('140106', 'La Victoria', '1401', '14'),
('140107', 'Lagunas', '1401', '14'),
('140108', 'Monsefu', '1401', '14'),
('140109', 'Nueva Arica', '1401', '14'),
('140110', 'Oyotun', '1401', '14'),
('140111', 'Picsi', '1401', '14'),
('140112', 'Pimentel', '1401', '14'),
('140113', 'Reque', '1401', '14'),
('140114', 'Santa Rosa', '1401', '14'),
('140115', 'Saña', '1401', '14'),
('140116', 'Cayalti', '1401', '14'),
('140117', 'Patapo', '1401', '14'),
('140118', 'Pomalca', '1401', '14'),
('140119', 'Pucala', '1401', '14'),
('140120', 'Tuman', '1401', '14'),
('140201', 'Ferreñafe', '1402', '14'),
('140202', 'Cañaris', '1402', '14'),
('140203', 'Incahuasi', '1402', '14'),
('140204', 'Manuel Antonio Mesones Muro', '1402', '14'),
('140205', 'Pitipo', '1402', '14'),
('140206', 'Pueblo Nuevo', '1402', '14'),
('140301', 'Lambayeque', '1403', '14'),
('140302', 'Chochope', '1403', '14'),
('140303', 'Illimo', '1403', '14'),
('140304', 'Jayanca', '1403', '14'),
('140305', 'Mochumi', '1403', '14'),
('140306', 'Morrope', '1403', '14'),
('140307', 'Motupe', '1403', '14'),
('140308', 'Olmos', '1403', '14'),
('140309', 'Pacora', '1403', '14'),
('140310', 'Salas', '1403', '14'),
('140311', 'San José', '1403', '14'),
('140312', 'Tucume', '1403', '14'),
('150101', 'Lima', '1501', '15'),
('150102', 'Ancón', '1501', '15'),
('150103', 'Ate', '1501', '15'),
('150104', 'Barranco', '1501', '15'),
('150105', 'Breña', '1501', '15'),
('150106', 'Carabayllo', '1501', '15'),
('150107', 'Chaclacayo', '1501', '15'),
('150108', 'Chorrillos', '1501', '15'),
('150109', 'Cieneguilla', '1501', '15'),
('150110', 'Comas', '1501', '15'),
('150111', 'El Agustino', '1501', '15'),
('150112', 'Independencia', '1501', '15'),
('150113', 'Jesús María', '1501', '15'),
('150114', 'La Molina', '1501', '15'),
('150115', 'La Victoria', '1501', '15'),
('150116', 'Lince', '1501', '15'),
('150117', 'Los Olivos', '1501', '15'),
('150118', 'Lurigancho', '1501', '15'),
('150119', 'Lurin', '1501', '15'),
('150120', 'Magdalena del Mar', '1501', '15'),
('150121', 'Pueblo Libre', '1501', '15'),
('150122', 'Miraflores', '1501', '15'),
('150123', 'Pachacamac', '1501', '15'),
('150124', 'Pucusana', '1501', '15'),
('150125', 'Puente Piedra', '1501', '15'),
('150126', 'Punta Hermosa', '1501', '15'),
('150127', 'Punta Negra', '1501', '15'),
('150128', 'Rímac', '1501', '15'),
('150129', 'San Bartolo', '1501', '15'),
('150130', 'San Borja', '1501', '15'),
('150131', 'San Isidro', '1501', '15'),
('150132', 'San Juan de Lurigancho', '1501', '15'),
('150133', 'San Juan de Miraflores', '1501', '15'),
('150134', 'San Luis', '1501', '15'),
('150135', 'San Martín de Porres', '1501', '15'),
('150136', 'San Miguel', '1501', '15'),
('150137', 'Santa Anita', '1501', '15'),
('150138', 'Santa María del Mar', '1501', '15'),
('150139', 'Santa Rosa', '1501', '15'),
('150140', 'Santiago de Surco', '1501', '15'),
('150141', 'Surquillo', '1501', '15'),
('150142', 'Villa El Salvador', '1501', '15'),
('150143', 'Villa María del Triunfo', '1501', '15'),
('150201', 'Barranca', '1502', '15'),
('150202', 'Paramonga', '1502', '15'),
('150203', 'Pativilca', '1502', '15'),
('150204', 'Supe', '1502', '15'),
('150205', 'Supe Puerto', '1502', '15'),
('150301', 'Cajatambo', '1503', '15'),
('150302', 'Copa', '1503', '15'),
('150303', 'Gorgor', '1503', '15'),
('150304', 'Huancapon', '1503', '15'),
('150305', 'Manas', '1503', '15'),
('150401', 'Canta', '1504', '15'),
('150402', 'Arahuay', '1504', '15'),
('150403', 'Huamantanga', '1504', '15'),
('150404', 'Huaros', '1504', '15'),
('150405', 'Lachaqui', '1504', '15'),
('150406', 'San Buenaventura', '1504', '15'),
('150407', 'Santa Rosa de Quives', '1504', '15');
INSERT INTO `ubigeo_peru_districts` (`id`, `name`, `province_id`, `department_id`) VALUES
('150501', 'San Vicente de Cañete', '1505', '15'),
('150502', 'Asia', '1505', '15'),
('150503', 'Calango', '1505', '15'),
('150504', 'Cerro Azul', '1505', '15'),
('150505', 'Chilca', '1505', '15'),
('150506', 'Coayllo', '1505', '15'),
('150507', 'Imperial', '1505', '15'),
('150508', 'Lunahuana', '1505', '15'),
('150509', 'Mala', '1505', '15'),
('150510', 'Nuevo Imperial', '1505', '15'),
('150511', 'Pacaran', '1505', '15'),
('150512', 'Quilmana', '1505', '15'),
('150513', 'San Antonio', '1505', '15'),
('150514', 'San Luis', '1505', '15'),
('150515', 'Santa Cruz de Flores', '1505', '15'),
('150516', 'Zúñiga', '1505', '15'),
('150601', 'Huaral', '1506', '15'),
('150602', 'Atavillos Alto', '1506', '15'),
('150603', 'Atavillos Bajo', '1506', '15'),
('150604', 'Aucallama', '1506', '15'),
('150605', 'Chancay', '1506', '15'),
('150606', 'Ihuari', '1506', '15'),
('150607', 'Lampian', '1506', '15'),
('150608', 'Pacaraos', '1506', '15'),
('150609', 'San Miguel de Acos', '1506', '15'),
('150610', 'Santa Cruz de Andamarca', '1506', '15'),
('150611', 'Sumbilca', '1506', '15'),
('150612', 'Veintisiete de Noviembre', '1506', '15'),
('150701', 'Matucana', '1507', '15'),
('150702', 'Antioquia', '1507', '15'),
('150703', 'Callahuanca', '1507', '15'),
('150704', 'Carampoma', '1507', '15'),
('150705', 'Chicla', '1507', '15'),
('150706', 'Cuenca', '1507', '15'),
('150707', 'Huachupampa', '1507', '15'),
('150708', 'Huanza', '1507', '15'),
('150709', 'Huarochiri', '1507', '15'),
('150710', 'Lahuaytambo', '1507', '15'),
('150711', 'Langa', '1507', '15'),
('150712', 'Laraos', '1507', '15'),
('150713', 'Mariatana', '1507', '15'),
('150714', 'Ricardo Palma', '1507', '15'),
('150715', 'San Andrés de Tupicocha', '1507', '15'),
('150716', 'San Antonio', '1507', '15'),
('150717', 'San Bartolomé', '1507', '15'),
('150718', 'San Damian', '1507', '15'),
('150719', 'San Juan de Iris', '1507', '15'),
('150720', 'San Juan de Tantaranche', '1507', '15'),
('150721', 'San Lorenzo de Quinti', '1507', '15'),
('150722', 'San Mateo', '1507', '15'),
('150723', 'San Mateo de Otao', '1507', '15'),
('150724', 'San Pedro de Casta', '1507', '15'),
('150725', 'San Pedro de Huancayre', '1507', '15'),
('150726', 'Sangallaya', '1507', '15'),
('150727', 'Santa Cruz de Cocachacra', '1507', '15'),
('150728', 'Santa Eulalia', '1507', '15'),
('150729', 'Santiago de Anchucaya', '1507', '15'),
('150730', 'Santiago de Tuna', '1507', '15'),
('150731', 'Santo Domingo de Los Olleros', '1507', '15'),
('150732', 'Surco', '1507', '15'),
('150801', 'Huacho', '1508', '15'),
('150802', 'Ambar', '1508', '15'),
('150803', 'Caleta de Carquin', '1508', '15'),
('150804', 'Checras', '1508', '15'),
('150805', 'Hualmay', '1508', '15'),
('150806', 'Huaura', '1508', '15'),
('150807', 'Leoncio Prado', '1508', '15'),
('150808', 'Paccho', '1508', '15'),
('150809', 'Santa Leonor', '1508', '15'),
('150810', 'Santa María', '1508', '15'),
('150811', 'Sayan', '1508', '15'),
('150812', 'Vegueta', '1508', '15'),
('150901', 'Oyon', '1509', '15'),
('150902', 'Andajes', '1509', '15'),
('150903', 'Caujul', '1509', '15'),
('150904', 'Cochamarca', '1509', '15'),
('150905', 'Navan', '1509', '15'),
('150906', 'Pachangara', '1509', '15'),
('151001', 'Yauyos', '1510', '15'),
('151002', 'Alis', '1510', '15'),
('151003', 'Allauca', '1510', '15'),
('151004', 'Ayaviri', '1510', '15'),
('151005', 'Azángaro', '1510', '15'),
('151006', 'Cacra', '1510', '15'),
('151007', 'Carania', '1510', '15'),
('151008', 'Catahuasi', '1510', '15'),
('151009', 'Chocos', '1510', '15'),
('151010', 'Cochas', '1510', '15'),
('151011', 'Colonia', '1510', '15'),
('151012', 'Hongos', '1510', '15'),
('151013', 'Huampara', '1510', '15'),
('151014', 'Huancaya', '1510', '15'),
('151015', 'Huangascar', '1510', '15'),
('151016', 'Huantan', '1510', '15'),
('151017', 'Huañec', '1510', '15'),
('151018', 'Laraos', '1510', '15'),
('151019', 'Lincha', '1510', '15'),
('151020', 'Madean', '1510', '15'),
('151021', 'Miraflores', '1510', '15'),
('151022', 'Omas', '1510', '15'),
('151023', 'Putinza', '1510', '15'),
('151024', 'Quinches', '1510', '15'),
('151025', 'Quinocay', '1510', '15'),
('151026', 'San Joaquín', '1510', '15'),
('151027', 'San Pedro de Pilas', '1510', '15'),
('151028', 'Tanta', '1510', '15'),
('151029', 'Tauripampa', '1510', '15'),
('151030', 'Tomas', '1510', '15'),
('151031', 'Tupe', '1510', '15'),
('151032', 'Viñac', '1510', '15'),
('151033', 'Vitis', '1510', '15'),
('160101', 'Iquitos', '1601', '16'),
('160102', 'Alto Nanay', '1601', '16'),
('160103', 'Fernando Lores', '1601', '16'),
('160104', 'Indiana', '1601', '16'),
('160105', 'Las Amazonas', '1601', '16'),
('160106', 'Mazan', '1601', '16'),
('160107', 'Napo', '1601', '16'),
('160108', 'Punchana', '1601', '16'),
('160110', 'Torres Causana', '1601', '16'),
('160112', 'Belén', '1601', '16'),
('160113', 'San Juan Bautista', '1601', '16'),
('160201', 'Yurimaguas', '1602', '16'),
('160202', 'Balsapuerto', '1602', '16'),
('160205', 'Jeberos', '1602', '16'),
('160206', 'Lagunas', '1602', '16'),
('160210', 'Santa Cruz', '1602', '16'),
('160211', 'Teniente Cesar López Rojas', '1602', '16'),
('160301', 'Nauta', '1603', '16'),
('160302', 'Parinari', '1603', '16'),
('160303', 'Tigre', '1603', '16'),
('160304', 'Trompeteros', '1603', '16'),
('160305', 'Urarinas', '1603', '16'),
('160401', 'Ramón Castilla', '1604', '16'),
('160402', 'Pebas', '1604', '16'),
('160403', 'Yavari', '1604', '16'),
('160404', 'San Pablo', '1604', '16'),
('160501', 'Requena', '1605', '16'),
('160502', 'Alto Tapiche', '1605', '16'),
('160503', 'Capelo', '1605', '16'),
('160504', 'Emilio San Martín', '1605', '16'),
('160505', 'Maquia', '1605', '16'),
('160506', 'Puinahua', '1605', '16'),
('160507', 'Saquena', '1605', '16'),
('160508', 'Soplin', '1605', '16'),
('160509', 'Tapiche', '1605', '16'),
('160510', 'Jenaro Herrera', '1605', '16'),
('160511', 'Yaquerana', '1605', '16'),
('160601', 'Contamana', '1606', '16'),
('160602', 'Inahuaya', '1606', '16'),
('160603', 'Padre Márquez', '1606', '16'),
('160604', 'Pampa Hermosa', '1606', '16'),
('160605', 'Sarayacu', '1606', '16'),
('160606', 'Vargas Guerra', '1606', '16'),
('160701', 'Barranca', '1607', '16'),
('160702', 'Cahuapanas', '1607', '16'),
('160703', 'Manseriche', '1607', '16'),
('160704', 'Morona', '1607', '16'),
('160705', 'Pastaza', '1607', '16'),
('160706', 'Andoas', '1607', '16'),
('160801', 'Putumayo', '1608', '16'),
('160802', 'Rosa Panduro', '1608', '16'),
('160803', 'Teniente Manuel Clavero', '1608', '16'),
('160804', 'Yaguas', '1608', '16'),
('170101', 'Tambopata', '1701', '17'),
('170102', 'Inambari', '1701', '17'),
('170103', 'Las Piedras', '1701', '17'),
('170104', 'Laberinto', '1701', '17'),
('170201', 'Manu', '1702', '17'),
('170202', 'Fitzcarrald', '1702', '17'),
('170203', 'Madre de Dios', '1702', '17'),
('170204', 'Huepetuhe', '1702', '17'),
('170301', 'Iñapari', '1703', '17'),
('170302', 'Iberia', '1703', '17'),
('170303', 'Tahuamanu', '1703', '17'),
('180101', 'Moquegua', '1801', '18'),
('180102', 'Carumas', '1801', '18'),
('180103', 'Cuchumbaya', '1801', '18'),
('180104', 'Samegua', '1801', '18'),
('180105', 'San Cristóbal', '1801', '18'),
('180106', 'Torata', '1801', '18'),
('180201', 'Omate', '1802', '18'),
('180202', 'Chojata', '1802', '18'),
('180203', 'Coalaque', '1802', '18'),
('180204', 'Ichuña', '1802', '18'),
('180205', 'La Capilla', '1802', '18'),
('180206', 'Lloque', '1802', '18'),
('180207', 'Matalaque', '1802', '18'),
('180208', 'Puquina', '1802', '18'),
('180209', 'Quinistaquillas', '1802', '18'),
('180210', 'Ubinas', '1802', '18'),
('180211', 'Yunga', '1802', '18'),
('180301', 'Ilo', '1803', '18'),
('180302', 'El Algarrobal', '1803', '18'),
('180303', 'Pacocha', '1803', '18'),
('190101', 'Chaupimarca', '1901', '19'),
('190102', 'Huachon', '1901', '19'),
('190103', 'Huariaca', '1901', '19'),
('190104', 'Huayllay', '1901', '19'),
('190105', 'Ninacaca', '1901', '19'),
('190106', 'Pallanchacra', '1901', '19'),
('190107', 'Paucartambo', '1901', '19'),
('190108', 'San Francisco de Asís de Yarusyacan', '1901', '19'),
('190109', 'Simon Bolívar', '1901', '19'),
('190110', 'Ticlacayan', '1901', '19'),
('190111', 'Tinyahuarco', '1901', '19'),
('190112', 'Vicco', '1901', '19'),
('190113', 'Yanacancha', '1901', '19'),
('190201', 'Yanahuanca', '1902', '19'),
('190202', 'Chacayan', '1902', '19'),
('190203', 'Goyllarisquizga', '1902', '19'),
('190204', 'Paucar', '1902', '19'),
('190205', 'San Pedro de Pillao', '1902', '19'),
('190206', 'Santa Ana de Tusi', '1902', '19'),
('190207', 'Tapuc', '1902', '19'),
('190208', 'Vilcabamba', '1902', '19'),
('190301', 'Oxapampa', '1903', '19'),
('190302', 'Chontabamba', '1903', '19'),
('190303', 'Huancabamba', '1903', '19'),
('190304', 'Palcazu', '1903', '19'),
('190305', 'Pozuzo', '1903', '19'),
('190306', 'Puerto Bermúdez', '1903', '19'),
('190307', 'Villa Rica', '1903', '19'),
('190308', 'Constitución', '1903', '19'),
('200101', 'Piura', '2001', '20'),
('200104', 'Castilla', '2001', '20'),
('200105', 'Catacaos', '2001', '20'),
('200107', 'Cura Mori', '2001', '20'),
('200108', 'El Tallan', '2001', '20'),
('200109', 'La Arena', '2001', '20'),
('200110', 'La Unión', '2001', '20'),
('200111', 'Las Lomas', '2001', '20'),
('200114', 'Tambo Grande', '2001', '20'),
('200115', 'Veintiseis de Octubre', '2001', '20'),
('200201', 'Ayabaca', '2002', '20'),
('200202', 'Frias', '2002', '20'),
('200203', 'Jilili', '2002', '20'),
('200204', 'Lagunas', '2002', '20'),
('200205', 'Montero', '2002', '20'),
('200206', 'Pacaipampa', '2002', '20'),
('200207', 'Paimas', '2002', '20'),
('200208', 'Sapillica', '2002', '20'),
('200209', 'Sicchez', '2002', '20'),
('200210', 'Suyo', '2002', '20'),
('200301', 'Huancabamba', '2003', '20'),
('200302', 'Canchaque', '2003', '20'),
('200303', 'El Carmen de la Frontera', '2003', '20'),
('200304', 'Huarmaca', '2003', '20'),
('200305', 'Lalaquiz', '2003', '20'),
('200306', 'San Miguel de El Faique', '2003', '20'),
('200307', 'Sondor', '2003', '20'),
('200308', 'Sondorillo', '2003', '20'),
('200401', 'Chulucanas', '2004', '20'),
('200402', 'Buenos Aires', '2004', '20'),
('200403', 'Chalaco', '2004', '20'),
('200404', 'La Matanza', '2004', '20'),
('200405', 'Morropon', '2004', '20'),
('200406', 'Salitral', '2004', '20'),
('200407', 'San Juan de Bigote', '2004', '20'),
('200408', 'Santa Catalina de Mossa', '2004', '20'),
('200409', 'Santo Domingo', '2004', '20'),
('200410', 'Yamango', '2004', '20'),
('200501', 'Paita', '2005', '20'),
('200502', 'Amotape', '2005', '20'),
('200503', 'Arenal', '2005', '20'),
('200504', 'Colan', '2005', '20'),
('200505', 'La Huaca', '2005', '20'),
('200506', 'Tamarindo', '2005', '20'),
('200507', 'Vichayal', '2005', '20'),
('200601', 'Sullana', '2006', '20'),
('200602', 'Bellavista', '2006', '20'),
('200603', 'Ignacio Escudero', '2006', '20'),
('200604', 'Lancones', '2006', '20'),
('200605', 'Marcavelica', '2006', '20'),
('200606', 'Miguel Checa', '2006', '20'),
('200607', 'Querecotillo', '2006', '20'),
('200608', 'Salitral', '2006', '20'),
('200701', 'Pariñas', '2007', '20'),
('200702', 'El Alto', '2007', '20'),
('200703', 'La Brea', '2007', '20'),
('200704', 'Lobitos', '2007', '20'),
('200705', 'Los Organos', '2007', '20'),
('200706', 'Mancora', '2007', '20'),
('200801', 'Sechura', '2008', '20'),
('200802', 'Bellavista de la Unión', '2008', '20'),
('200803', 'Bernal', '2008', '20'),
('200804', 'Cristo Nos Valga', '2008', '20'),
('200805', 'Vice', '2008', '20'),
('200806', 'Rinconada Llicuar', '2008', '20'),
('210101', 'Puno', '2101', '21'),
('210102', 'Acora', '2101', '21'),
('210103', 'Amantani', '2101', '21'),
('210104', 'Atuncolla', '2101', '21'),
('210105', 'Capachica', '2101', '21'),
('210106', 'Chucuito', '2101', '21'),
('210107', 'Coata', '2101', '21'),
('210108', 'Huata', '2101', '21'),
('210109', 'Mañazo', '2101', '21'),
('210110', 'Paucarcolla', '2101', '21'),
('210111', 'Pichacani', '2101', '21'),
('210112', 'Plateria', '2101', '21'),
('210113', 'San Antonio', '2101', '21'),
('210114', 'Tiquillaca', '2101', '21'),
('210115', 'Vilque', '2101', '21'),
('210201', 'Azángaro', '2102', '21'),
('210202', 'Achaya', '2102', '21'),
('210203', 'Arapa', '2102', '21'),
('210204', 'Asillo', '2102', '21'),
('210205', 'Caminaca', '2102', '21'),
('210206', 'Chupa', '2102', '21'),
('210207', 'José Domingo Choquehuanca', '2102', '21'),
('210208', 'Muñani', '2102', '21'),
('210209', 'Potoni', '2102', '21'),
('210210', 'Saman', '2102', '21'),
('210211', 'San Anton', '2102', '21'),
('210212', 'San José', '2102', '21'),
('210213', 'San Juan de Salinas', '2102', '21'),
('210214', 'Santiago de Pupuja', '2102', '21'),
('210215', 'Tirapata', '2102', '21'),
('210301', 'Macusani', '2103', '21'),
('210302', 'Ajoyani', '2103', '21'),
('210303', 'Ayapata', '2103', '21'),
('210304', 'Coasa', '2103', '21'),
('210305', 'Corani', '2103', '21'),
('210306', 'Crucero', '2103', '21'),
('210307', 'Ituata', '2103', '21'),
('210308', 'Ollachea', '2103', '21'),
('210309', 'San Gaban', '2103', '21'),
('210310', 'Usicayos', '2103', '21'),
('210401', 'Juli', '2104', '21'),
('210402', 'Desaguadero', '2104', '21'),
('210403', 'Huacullani', '2104', '21'),
('210404', 'Kelluyo', '2104', '21'),
('210405', 'Pisacoma', '2104', '21'),
('210406', 'Pomata', '2104', '21'),
('210407', 'Zepita', '2104', '21'),
('210501', 'Ilave', '2105', '21'),
('210502', 'Capazo', '2105', '21'),
('210503', 'Pilcuyo', '2105', '21'),
('210504', 'Santa Rosa', '2105', '21'),
('210505', 'Conduriri', '2105', '21'),
('210601', 'Huancane', '2106', '21'),
('210602', 'Cojata', '2106', '21'),
('210603', 'Huatasani', '2106', '21'),
('210604', 'Inchupalla', '2106', '21'),
('210605', 'Pusi', '2106', '21'),
('210606', 'Rosaspata', '2106', '21'),
('210607', 'Taraco', '2106', '21'),
('210608', 'Vilque Chico', '2106', '21'),
('210701', 'Lampa', '2107', '21'),
('210702', 'Cabanilla', '2107', '21'),
('210703', 'Calapuja', '2107', '21'),
('210704', 'Nicasio', '2107', '21'),
('210705', 'Ocuviri', '2107', '21'),
('210706', 'Palca', '2107', '21'),
('210707', 'Paratia', '2107', '21'),
('210708', 'Pucara', '2107', '21'),
('210709', 'Santa Lucia', '2107', '21'),
('210710', 'Vilavila', '2107', '21'),
('210801', 'Ayaviri', '2108', '21'),
('210802', 'Antauta', '2108', '21'),
('210803', 'Cupi', '2108', '21'),
('210804', 'Llalli', '2108', '21'),
('210805', 'Macari', '2108', '21'),
('210806', 'Nuñoa', '2108', '21'),
('210807', 'Orurillo', '2108', '21'),
('210808', 'Santa Rosa', '2108', '21'),
('210809', 'Umachiri', '2108', '21'),
('210901', 'Moho', '2109', '21'),
('210902', 'Conima', '2109', '21'),
('210903', 'Huayrapata', '2109', '21'),
('210904', 'Tilali', '2109', '21'),
('211001', 'Putina', '2110', '21'),
('211002', 'Ananea', '2110', '21'),
('211003', 'Pedro Vilca Apaza', '2110', '21'),
('211004', 'Quilcapuncu', '2110', '21'),
('211005', 'Sina', '2110', '21'),
('211101', 'Juliaca', '2111', '21'),
('211102', 'Cabana', '2111', '21'),
('211103', 'Cabanillas', '2111', '21'),
('211104', 'Caracoto', '2111', '21'),
('211105', 'San Miguel', '2111', '21'),
('211201', 'Sandia', '2112', '21'),
('211202', 'Cuyocuyo', '2112', '21'),
('211203', 'Limbani', '2112', '21'),
('211204', 'Patambuco', '2112', '21'),
('211205', 'Phara', '2112', '21'),
('211206', 'Quiaca', '2112', '21'),
('211207', 'San Juan del Oro', '2112', '21'),
('211208', 'Yanahuaya', '2112', '21'),
('211209', 'Alto Inambari', '2112', '21'),
('211210', 'San Pedro de Putina Punco', '2112', '21'),
('211301', 'Yunguyo', '2113', '21'),
('211302', 'Anapia', '2113', '21'),
('211303', 'Copani', '2113', '21'),
('211304', 'Cuturapi', '2113', '21'),
('211305', 'Ollaraya', '2113', '21'),
('211306', 'Tinicachi', '2113', '21'),
('211307', 'Unicachi', '2113', '21'),
('220101', 'Moyobamba', '2201', '22'),
('220102', 'Calzada', '2201', '22'),
('220103', 'Habana', '2201', '22'),
('220104', 'Jepelacio', '2201', '22'),
('220105', 'Soritor', '2201', '22'),
('220106', 'Yantalo', '2201', '22'),
('220201', 'Bellavista', '2202', '22'),
('220202', 'Alto Biavo', '2202', '22'),
('220203', 'Bajo Biavo', '2202', '22'),
('220204', 'Huallaga', '2202', '22'),
('220205', 'San Pablo', '2202', '22'),
('220206', 'San Rafael', '2202', '22'),
('220301', 'San José de Sisa', '2203', '22'),
('220302', 'Agua Blanca', '2203', '22'),
('220303', 'San Martín', '2203', '22'),
('220304', 'Santa Rosa', '2203', '22'),
('220305', 'Shatoja', '2203', '22'),
('220401', 'Saposoa', '2204', '22'),
('220402', 'Alto Saposoa', '2204', '22'),
('220403', 'El Eslabón', '2204', '22'),
('220404', 'Piscoyacu', '2204', '22'),
('220405', 'Sacanche', '2204', '22'),
('220406', 'Tingo de Saposoa', '2204', '22'),
('220501', 'Lamas', '2205', '22'),
('220502', 'Alonso de Alvarado', '2205', '22'),
('220503', 'Barranquita', '2205', '22'),
('220504', 'Caynarachi', '2205', '22'),
('220505', 'Cuñumbuqui', '2205', '22'),
('220506', 'Pinto Recodo', '2205', '22'),
('220507', 'Rumisapa', '2205', '22'),
('220508', 'San Roque de Cumbaza', '2205', '22'),
('220509', 'Shanao', '2205', '22'),
('220510', 'Tabalosos', '2205', '22'),
('220511', 'Zapatero', '2205', '22'),
('220601', 'Juanjuí', '2206', '22'),
('220602', 'Campanilla', '2206', '22'),
('220603', 'Huicungo', '2206', '22'),
('220604', 'Pachiza', '2206', '22'),
('220605', 'Pajarillo', '2206', '22'),
('220701', 'Picota', '2207', '22'),
('220702', 'Buenos Aires', '2207', '22'),
('220703', 'Caspisapa', '2207', '22'),
('220704', 'Pilluana', '2207', '22'),
('220705', 'Pucacaca', '2207', '22'),
('220706', 'San Cristóbal', '2207', '22'),
('220707', 'San Hilarión', '2207', '22'),
('220708', 'Shamboyacu', '2207', '22'),
('220709', 'Tingo de Ponasa', '2207', '22'),
('220710', 'Tres Unidos', '2207', '22'),
('220801', 'Rioja', '2208', '22'),
('220802', 'Awajun', '2208', '22'),
('220803', 'Elías Soplin Vargas', '2208', '22'),
('220804', 'Nueva Cajamarca', '2208', '22'),
('220805', 'Pardo Miguel', '2208', '22'),
('220806', 'Posic', '2208', '22'),
('220807', 'San Fernando', '2208', '22'),
('220808', 'Yorongos', '2208', '22'),
('220809', 'Yuracyacu', '2208', '22'),
('220901', 'Tarapoto', '2209', '22'),
('220902', 'Alberto Leveau', '2209', '22'),
('220903', 'Cacatachi', '2209', '22'),
('220904', 'Chazuta', '2209', '22'),
('220905', 'Chipurana', '2209', '22'),
('220906', 'El Porvenir', '2209', '22'),
('220907', 'Huimbayoc', '2209', '22'),
('220908', 'Juan Guerra', '2209', '22'),
('220909', 'La Banda de Shilcayo', '2209', '22'),
('220910', 'Morales', '2209', '22'),
('220911', 'Papaplaya', '2209', '22'),
('220912', 'San Antonio', '2209', '22'),
('220913', 'Sauce', '2209', '22'),
('220914', 'Shapaja', '2209', '22'),
('221001', 'Tocache', '2210', '22'),
('221002', 'Nuevo Progreso', '2210', '22'),
('221003', 'Polvora', '2210', '22'),
('221004', 'Shunte', '2210', '22'),
('221005', 'Uchiza', '2210', '22'),
('230101', 'Tacna', '2301', '23'),
('230102', 'Alto de la Alianza', '2301', '23'),
('230103', 'Calana', '2301', '23'),
('230104', 'Ciudad Nueva', '2301', '23'),
('230105', 'Inclan', '2301', '23'),
('230106', 'Pachia', '2301', '23'),
('230107', 'Palca', '2301', '23'),
('230108', 'Pocollay', '2301', '23'),
('230109', 'Sama', '2301', '23'),
('230110', 'Coronel Gregorio Albarracín Lanchipa', '2301', '23'),
('230111', 'La Yarada los Palos', '2301', '23'),
('230201', 'Candarave', '2302', '23'),
('230202', 'Cairani', '2302', '23'),
('230203', 'Camilaca', '2302', '23'),
('230204', 'Curibaya', '2302', '23'),
('230205', 'Huanuara', '2302', '23'),
('230206', 'Quilahuani', '2302', '23'),
('230301', 'Locumba', '2303', '23'),
('230302', 'Ilabaya', '2303', '23'),
('230303', 'Ite', '2303', '23'),
('230401', 'Tarata', '2304', '23'),
('230402', 'Héroes Albarracín', '2304', '23'),
('230403', 'Estique', '2304', '23'),
('230404', 'Estique-Pampa', '2304', '23'),
('230405', 'Sitajara', '2304', '23'),
('230406', 'Susapaya', '2304', '23'),
('230407', 'Tarucachi', '2304', '23'),
('230408', 'Ticaco', '2304', '23'),
('240101', 'Tumbes', '2401', '24'),
('240102', 'Corrales', '2401', '24'),
('240103', 'La Cruz', '2401', '24'),
('240104', 'Pampas de Hospital', '2401', '24'),
('240105', 'San Jacinto', '2401', '24'),
('240106', 'San Juan de la Virgen', '2401', '24'),
('240201', 'Zorritos', '2402', '24'),
('240202', 'Casitas', '2402', '24'),
('240203', 'Canoas de Punta Sal', '2402', '24'),
('240301', 'Zarumilla', '2403', '24'),
('240302', 'Aguas Verdes', '2403', '24'),
('240303', 'Matapalo', '2403', '24'),
('240304', 'Papayal', '2403', '24'),
('250101', 'Calleria', '2501', '25'),
('250102', 'Campoverde', '2501', '25'),
('250103', 'Iparia', '2501', '25'),
('250104', 'Masisea', '2501', '25'),
('250105', 'Yarinacocha', '2501', '25'),
('250106', 'Nueva Requena', '2501', '25'),
('250107', 'Manantay', '2501', '25'),
('250201', 'Raymondi', '2502', '25'),
('250202', 'Sepahua', '2502', '25'),
('250203', 'Tahuania', '2502', '25'),
('250204', 'Yurua', '2502', '25'),
('250301', 'Padre Abad', '2503', '25'),
('250302', 'Irazola', '2503', '25'),
('250303', 'Curimana', '2503', '25'),
('250304', 'Neshuya', '2503', '25'),
('250305', 'Alexander Von Humboldt', '2503', '25'),
('250401', 'Purus', '2504', '25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ubigeo_peru_provinces`
--

CREATE TABLE `ubigeo_peru_provinces` (
  `id` varchar(4) NOT NULL,
  `name` varchar(45) NOT NULL,
  `department_id` varchar(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `ubigeo_peru_provinces`
--

INSERT INTO `ubigeo_peru_provinces` (`id`, `name`, `department_id`) VALUES
('0101', 'Chachapoyas', '01'),
('0102', 'Bagua', '01'),
('0103', 'Bongará', '01'),
('0104', 'Condorcanqui', '01'),
('0105', 'Luya', '01'),
('0106', 'Rodríguez de Mendoza', '01'),
('0107', 'Utcubamba', '01'),
('0201', 'Huaraz', '02'),
('0202', 'Aija', '02'),
('0203', 'Antonio Raymondi', '02'),
('0204', 'Asunción', '02'),
('0205', 'Bolognesi', '02'),
('0206', 'Carhuaz', '02'),
('0207', 'Carlos Fermín Fitzcarrald', '02'),
('0208', 'Casma', '02'),
('0209', 'Corongo', '02'),
('0210', 'Huari', '02'),
('0211', 'Huarmey', '02'),
('0212', 'Huaylas', '02'),
('0213', 'Mariscal Luzuriaga', '02'),
('0214', 'Ocros', '02'),
('0215', 'Pallasca', '02'),
('0216', 'Pomabamba', '02'),
('0217', 'Recuay', '02'),
('0218', 'Santa', '02'),
('0219', 'Sihuas', '02'),
('0220', 'Yungay', '02'),
('0301', 'Abancay', '03'),
('0302', 'Andahuaylas', '03'),
('0303', 'Antabamba', '03'),
('0304', 'Aymaraes', '03'),
('0305', 'Cotabambas', '03'),
('0306', 'Chincheros', '03'),
('0307', 'Grau', '03'),
('0401', 'Arequipa', '04'),
('0402', 'Camaná', '04'),
('0403', 'Caravelí', '04'),
('0404', 'Castilla', '04'),
('0405', 'Caylloma', '04'),
('0406', 'Condesuyos', '04'),
('0407', 'Islay', '04'),
('0408', 'La Uniòn', '04'),
('0501', 'Huamanga', '05'),
('0502', 'Cangallo', '05'),
('0503', 'Huanca Sancos', '05'),
('0504', 'Huanta', '05'),
('0505', 'La Mar', '05'),
('0506', 'Lucanas', '05'),
('0507', 'Parinacochas', '05'),
('0508', 'Pàucar del Sara Sara', '05'),
('0509', 'Sucre', '05'),
('0510', 'Víctor Fajardo', '05'),
('0511', 'Vilcas Huamán', '05'),
('0601', 'Cajamarca', '06'),
('0602', 'Cajabamba', '06'),
('0603', 'Celendín', '06'),
('0604', 'Chota', '06'),
('0605', 'Contumazá', '06'),
('0606', 'Cutervo', '06'),
('0607', 'Hualgayoc', '06'),
('0608', 'Jaén', '06'),
('0609', 'San Ignacio', '06'),
('0610', 'San Marcos', '06'),
('0611', 'San Miguel', '06'),
('0612', 'San Pablo', '06'),
('0613', 'Santa Cruz', '06'),
('0701', 'Prov. Const. del Callao', '07'),
('0801', 'Cusco', '08'),
('0802', 'Acomayo', '08'),
('0803', 'Anta', '08'),
('0804', 'Calca', '08'),
('0805', 'Canas', '08'),
('0806', 'Canchis', '08'),
('0807', 'Chumbivilcas', '08'),
('0808', 'Espinar', '08'),
('0809', 'La Convención', '08'),
('0810', 'Paruro', '08'),
('0811', 'Paucartambo', '08'),
('0812', 'Quispicanchi', '08'),
('0813', 'Urubamba', '08'),
('0901', 'Huancavelica', '09'),
('0902', 'Acobamba', '09'),
('0903', 'Angaraes', '09'),
('0904', 'Castrovirreyna', '09'),
('0905', 'Churcampa', '09'),
('0906', 'Huaytará', '09'),
('0907', 'Tayacaja', '09'),
('1001', 'Huánuco', '10'),
('1002', 'Ambo', '10'),
('1003', 'Dos de Mayo', '10'),
('1004', 'Huacaybamba', '10'),
('1005', 'Huamalíes', '10'),
('1006', 'Leoncio Prado', '10'),
('1007', 'Marañón', '10'),
('1008', 'Pachitea', '10'),
('1009', 'Puerto Inca', '10'),
('1010', 'Lauricocha ', '10'),
('1011', 'Yarowilca ', '10'),
('1101', 'Ica ', '11'),
('1102', 'Chincha ', '11'),
('1103', 'Nasca ', '11'),
('1104', 'Palpa ', '11'),
('1105', 'Pisco ', '11'),
('1201', 'Huancayo ', '12'),
('1202', 'Concepción ', '12'),
('1203', 'Chanchamayo ', '12'),
('1204', 'Jauja ', '12'),
('1205', 'Junín ', '12'),
('1206', 'Satipo ', '12'),
('1207', 'Tarma ', '12'),
('1208', 'Yauli ', '12'),
('1209', 'Chupaca ', '12'),
('1301', 'Trujillo ', '13'),
('1302', 'Ascope ', '13'),
('1303', 'Bolívar ', '13'),
('1304', 'Chepén ', '13'),
('1305', 'Julcán ', '13'),
('1306', 'Otuzco ', '13'),
('1307', 'Pacasmayo ', '13'),
('1308', 'Pataz ', '13'),
('1309', 'Sánchez Carrión ', '13'),
('1310', 'Santiago de Chuco ', '13'),
('1311', 'Gran Chimú ', '13'),
('1312', 'Virú ', '13'),
('1401', 'Chiclayo ', '14'),
('1402', 'Ferreñafe ', '14'),
('1403', 'Lambayeque ', '14'),
('1501', 'Lima ', '15'),
('1502', 'Barranca ', '15'),
('1503', 'Cajatambo ', '15'),
('1504', 'Canta ', '15'),
('1505', 'Cañete ', '15'),
('1506', 'Huaral ', '15'),
('1507', 'Huarochirí ', '15'),
('1508', 'Huaura ', '15'),
('1509', 'Oyón ', '15'),
('1510', 'Yauyos ', '15'),
('1601', 'Maynas ', '16'),
('1602', 'Alto Amazonas ', '16'),
('1603', 'Loreto ', '16'),
('1604', 'Mariscal Ramón Castilla ', '16'),
('1605', 'Requena ', '16'),
('1606', 'Ucayali ', '16'),
('1607', 'Datem del Marañón ', '16'),
('1608', 'Putumayo', '16'),
('1701', 'Tambopata ', '17'),
('1702', 'Manu ', '17'),
('1703', 'Tahuamanu ', '17'),
('1801', 'Mariscal Nieto ', '18'),
('1802', 'General Sánchez Cerro ', '18'),
('1803', 'Ilo ', '18'),
('1901', 'Pasco ', '19'),
('1902', 'Daniel Alcides Carrión ', '19'),
('1903', 'Oxapampa ', '19'),
('2001', 'Piura ', '20'),
('2002', 'Ayabaca ', '20'),
('2003', 'Huancabamba ', '20'),
('2004', 'Morropón ', '20'),
('2005', 'Paita ', '20'),
('2006', 'Sullana ', '20'),
('2007', 'Talara ', '20'),
('2008', 'Sechura ', '20'),
('2101', 'Puno ', '21'),
('2102', 'Azángaro ', '21'),
('2103', 'Carabaya ', '21'),
('2104', 'Chucuito ', '21'),
('2105', 'El Collao ', '21'),
('2106', 'Huancané ', '21'),
('2107', 'Lampa ', '21'),
('2108', 'Melgar ', '21'),
('2109', 'Moho ', '21'),
('2110', 'San Antonio de Putina ', '21'),
('2111', 'San Román ', '21'),
('2112', 'Sandia ', '21'),
('2113', 'Yunguyo ', '21'),
('2201', 'Moyobamba ', '22'),
('2202', 'Bellavista ', '22'),
('2203', 'El Dorado ', '22'),
('2204', 'Huallaga ', '22'),
('2205', 'Lamas ', '22'),
('2206', 'Mariscal Cáceres ', '22'),
('2207', 'Picota ', '22'),
('2208', 'Rioja ', '22'),
('2209', 'San Martín ', '22'),
('2210', 'Tocache ', '22'),
('2301', 'Tacna ', '23'),
('2302', 'Candarave ', '23'),
('2303', 'Jorge Basadre ', '23'),
('2304', 'Tarata ', '23'),
('2401', 'Tumbes ', '24'),
('2402', 'Contralmirante Villar ', '24'),
('2403', 'Zarumilla ', '24'),
('2501', 'Coronel Portillo ', '25'),
('2502', 'Atalaya ', '25'),
('2503', 'Padre Abad ', '25'),
('2504', 'Purús', '25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `id_unidad_medida` int(11) NOT NULL,
  `um_name` varchar(50) NOT NULL,
  `um_status` varchar(20) NOT NULL,
  `um_fecha_creacion` timestamp NULL DEFAULT NULL,
  `um_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `unidad_medida`
--

INSERT INTO `unidad_medida` (`id_unidad_medida`, `um_name`, `um_status`, `um_fecha_creacion`, `um_code`) VALUES
(1, 'BOBINAS', 'active', '2021-08-19 12:59:08', '4A'),
(2, 'BALDE', 'active', '2021-08-19 12:59:33', 'BJ'),
(3, 'BARRILES', 'active', '2021-08-19 12:59:54', 'BLL'),
(4, 'BOLSA', 'active', '2021-08-19 13:00:07', 'BG'),
(5, 'BOTELLAS', 'active', '2021-08-19 13:00:30', 'BO'),
(6, 'CAJA', 'active', '2021-08-19 13:00:57', 'BX'),
(7, 'CARTONES', 'active', '2021-08-19 13:01:15', 'CT'),
(8, 'CENTIMETRO CUADRADO', 'active', '2021-08-19 13:01:40', 'CMK'),
(9, 'CENTIMETRO CUBICO', 'active', '2021-08-19 13:01:56', 'CMQ'),
(10, 'CENTIMETRO LINEAL', 'active', '2021-08-19 13:02:25', 'CMT'),
(11, 'CIENTO DE UNIDADES', 'active', '2021-08-19 13:02:40', 'CEN'),
(12, 'CILINDRO', 'active', '2021-08-19 13:02:59', 'CY'),
(13, 'CONOS', 'active', '2021-08-19 13:03:21', 'CJ'),
(14, 'DOCENA', 'active', '2021-08-19 13:03:47', 'DZN'),
(15, 'DOCENA POR 10**6', 'active', '2021-08-19 13:04:22', 'DZP'),
(16, 'FARDO', 'active', '2021-08-19 13:04:36', 'BE'),
(17, 'GALON INGLES (4,545956L)', 'active', '2021-08-19 13:04:55', 'GLI'),
(18, 'GRAMO', 'active', '2021-08-19 13:05:17', 'GRM'),
(19, 'GRUESA', 'active', '2021-08-19 13:05:30', 'GRO'),
(20, 'HECTOLITRO', 'active', '2021-08-19 13:05:51', 'HLT'),
(21, 'HOJA\r\n', 'active', '2021-08-19 13:06:16', 'LEF'),
(22, 'JUEGO', 'active', '2021-08-19 13:07:57', 'SET'),
(23, 'KILOGRAMO\r\n', 'active', '2021-08-19 13:08:16', 'KGM'),
(24, 'KILOMETRO', 'active', '2021-08-19 13:08:33', 'KTM'),
(25, 'KILOVATIO HORA', 'active', '2021-08-19 13:08:54', 'KWH'),
(26, 'KIT', 'active', '2021-08-19 13:09:21', 'KT'),
(27, 'LATAS', 'active', '2021-08-19 13:09:33', 'CA'),
(28, 'LIBRAS', 'active', '2021-08-19 13:09:58', 'LBR'),
(29, 'LITRO', 'active', '2021-08-19 13:10:16', 'LTR'),
(30, 'MEGAWATT HORA', 'active', '2021-08-19 13:10:35', 'MWH'),
(31, 'METRO', 'active', '2021-08-19 13:10:55', 'MTR'),
(32, 'METRO CUADRADO\r\n', 'active', '2021-08-19 13:11:16', 'MTK'),
(33, 'METRO CUBICO', 'active', '2021-08-19 13:11:32', 'MTQ'),
(34, 'MILIGRAMOS', 'active', '2021-08-19 13:11:49', 'MGM'),
(35, 'MILILITRO', 'active', '2021-08-19 13:12:07', 'MLT'),
(36, 'MILIMETRO', 'active', '2021-08-19 13:12:20', 'MMT'),
(37, 'MILIMETRO CUADRADO', 'active', '2021-08-19 13:12:41', 'MMK'),
(38, 'MILIMETRO CUBICO', 'active', '2021-08-19 13:12:59', 'MMQ'),
(39, 'MILLARES\r\n', 'active', '2021-08-19 13:13:14', 'MLL'),
(40, 'MILLON DE UNIDADES', 'active', '2021-08-19 13:13:33', 'UM'),
(41, 'ONZAS', 'active', '2021-08-19 13:13:53', 'ONZ'),
(42, 'PALETAS', 'active', '2021-08-19 13:14:08', 'PF'),
(43, 'PAQUETE\r\n', 'active', '2021-08-19 13:14:29', 'PK'),
(44, 'PAR', 'active', '2021-08-19 13:14:51', 'PR'),
(45, 'PIES', 'active', '2021-08-19 13:15:05', 'FOT'),
(46, 'PIES CUADRADOS', 'active', '2021-08-19 13:15:20', 'FTK'),
(47, 'PIES CUBICOS', 'active', '2021-08-19 13:15:37', 'FTQ'),
(48, 'PIEZAS', 'active', '2021-08-19 13:15:52', 'C62'),
(49, 'PLACAS', 'active', '2021-08-19 13:16:10', 'PG'),
(50, 'PLIEGO', 'active', '2021-08-19 13:16:27', 'ST'),
(51, 'PULGADAS', 'active', '2021-08-19 13:16:49', 'INH'),
(52, 'RESMA', 'active', '2021-08-19 13:17:07', 'RM'),
(53, 'TAMBOR', 'active', '2021-08-19 13:17:34', 'DR'),
(54, 'TONELADA CORTA', 'active', '2021-08-19 13:17:58', 'STN'),
(55, 'TONELADA LARGA', 'active', '2021-08-19 13:18:14', 'LTN'),
(56, 'TONELADAS', 'active', '2021-08-19 13:18:28', 'TNE'),
(57, 'TUBOS', 'active', '2021-08-19 13:18:48', 'TU'),
(58, 'UNIDAD (BIENES)', 'active', '2021-08-19 13:19:06', 'NIU'),
(59, 'UNIDAD (SERVICIOS)', 'active', '2021-08-19 13:19:22', 'ZZ'),
(60, 'US GALON (3,7843 L)', 'active', '2021-08-19 13:19:50', 'GLL'),
(61, 'YARDA', 'active', '2021-08-19 13:20:05', 'YRD'),
(62, 'YARDA CUADRADA', 'active', '2021-08-19 13:20:31', 'YDK');

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
(59, 'deyvisgc', '$2y$10$y76W0r.tIqm8QAk2iNBztOP/onXWATOrxMHJxw2ocHdpoXIwe2xfK', 'active', 1, 'OEd1aUJta0w4RFlXbFBveFk4U01ONzFNRkZXaEdjRHJYdTRzUnBlWg==', 164, '{\"ciphertext\":\"StAkbKyB+vZ6Lkl33PJ20A==\",\"iv\":\"fd7fc47ce9503885e9e7a694fe96c049\",\"salt\":\"34f176290648fe72be3b2ab8c6e11eec4104fc3b042c83fc0ea91c761e8b29d5b78b30165d28a4ec9f9d2a95c23452c1a536509d08f92441456f536dd1a3f28d9279b3de60bbe7201e2f08eb9c00554bfe0d00d5b1163e58a6e0183b03dc3ea2d427d09991eab57b76ffcfac06975b7effe7835b632dbf4c66068b32c8152a038f386746584369fefa0eb0c6539960b8b1522e40c022b209d9459e6f1a1f3b4053a00f0ee7a66a2b8d0f235aad8a2df5261f5a57cdfeec2bab83f5c80e4f11f975526edcc2e283818ec69f18cbde27c0de236dbb5e0a63d3fb9eca256c5dd573447823c97dde9e6cd7d6f076b6d352f7adc4a3e647df11b7d5a41a78a968987e\"}');

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
-- Indices de la tabla `almacen`
--
ALTER TABLE `almacen`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  ADD PRIMARY KEY (`id_arqueo_caja`);

--
-- Indices de la tabla `auditoria_universal`
--
ALTER TABLE `auditoria_universal`
  ADD PRIMARY KEY (`id`);

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
-- Indices de la tabla `historial_traslado`
--
ALTER TABLE `historial_traslado`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `icon`
--
ALTER TABLE `icon`
  ADD PRIMARY KEY (`id_icon`),
  ADD UNIQUE KEY `icon_id_icon_uindex` (`id_icon`);

--
-- Indices de la tabla `impuestos`
--
ALTER TABLE `impuestos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `inventario`
--
ALTER TABLE `inventario`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`id_persona`),
  ADD KEY `persona_tipo_cliente_proveedor_id_fk` (`id_tipo_cliente_proveedor`);

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
  ADD KEY `fk_product_unidad_medida1_idx` (`id_unidad_medida`),
  ADD KEY `fk_id_almacen_product__index` (`id_almacen`),
  ADD KEY `product_clase_producto_id_sub_clase_producto_fk` (`id_subclase`);

--
-- Indices de la tabla `product_history`
--
ALTER TABLE `product_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_history_id_lote_index` (`id_lote`),
  ADD KEY `product_history_id_producto_index` (`id_producto`);

--
-- Indices de la tabla `product_por_lotes`
--
ALTER TABLE `product_por_lotes`
  ADD PRIMARY KEY (`id_lote`);

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
-- Indices de la tabla `serie_compra`
--
ALTER TABLE `serie_compra`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tipo_afectacion`
--
ALTER TABLE `tipo_afectacion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `tipo_cliente_proveedor`
--
ALTER TABLE `tipo_cliente_proveedor`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `traslado`
--
ALTER TABLE `traslado`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ubigeo_peru_departments`
--
ALTER TABLE `ubigeo_peru_departments`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ubigeo_peru_districts`
--
ALTER TABLE `ubigeo_peru_districts`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ubigeo_peru_provinces`
--
ALTER TABLE `ubigeo_peru_provinces`
  ADD PRIMARY KEY (`id`);

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
  ADD KEY `fk_user_rol1_idx` (`id_rol`),
  ADD KEY `users_id_persona_index` (`id_persona`);

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
-- AUTO_INCREMENT de la tabla `almacen`
--
ALTER TABLE `almacen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `arqueo_caja`
--
ALTER TABLE `arqueo_caja`
  MODIFY `id_arqueo_caja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `auditoria_universal`
--
ALTER TABLE `auditoria_universal`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `id_caja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `id_caja_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT de la tabla `carrito`
--
ALTER TABLE `carrito`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=202;

--
-- AUTO_INCREMENT de la tabla `clase_producto`
--
ALTER TABLE `clase_producto`
  MODIFY `id_clase_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

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
-- AUTO_INCREMENT de la tabla `historial_traslado`
--
ALTER TABLE `historial_traslado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `icon`
--
ALTER TABLE `icon`
  MODIFY `id_icon` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT de la tabla `impuestos`
--
ALTER TABLE `impuestos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `inventario`
--
ALTER TABLE `inventario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=203;

--
-- AUTO_INCREMENT de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  MODIFY `id_privilegio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT de la tabla `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=409;

--
-- AUTO_INCREMENT de la tabla `product_history`
--
ALTER TABLE `product_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `product_por_lotes`
--
ALTER TABLE `product_por_lotes`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

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
  MODIFY `idrol_has_privilegio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT de la tabla `sangria`
--
ALTER TABLE `sangria`
  MODIFY `id_sangria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT de la tabla `serie_compra`
--
ALTER TABLE `serie_compra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_afectacion`
--
ALTER TABLE `tipo_afectacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `tipo_cliente_proveedor`
--
ALTER TABLE `tipo_cliente_proveedor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `traslado`
--
ALTER TABLE `traslado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `id_unidad_medida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

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
-- Filtros para la tabla `persona`
--
ALTER TABLE `persona`
  ADD CONSTRAINT `persona_tipo_cliente_proveedor_id_fk` FOREIGN KEY (`id_tipo_cliente_proveedor`) REFERENCES `tipo_cliente_proveedor` (`id`);

--
-- Filtros para la tabla `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `FK_id_almacen_product___fk` FOREIGN KEY (`id_almacen`) REFERENCES `almacen` (`id`),
  ADD CONSTRAINT `fk_product_unidad_medida1` FOREIGN KEY (`id_unidad_medida`) REFERENCES `unidad_medida` (`id_unidad_medida`) ON UPDATE CASCADE,
  ADD CONSTRAINT `product_clase_producto_id_clase_producto_fk` FOREIGN KEY (`id_clase_producto`) REFERENCES `clase_producto` (`id_clase_producto`) ON UPDATE CASCADE,
  ADD CONSTRAINT `product_clase_producto_id_sub_clase_producto_fk` FOREIGN KEY (`id_subclase`) REFERENCES `clase_producto` (`id_clase_producto`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `product_history`
--
ALTER TABLE `product_history`
  ADD CONSTRAINT `fk_product_id_lote` FOREIGN KEY (`id_lote`) REFERENCES `product_por_lotes` (`id_lote`) ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_product_id_product` FOREIGN KEY (`id_producto`) REFERENCES `product` (`id_product`) ON UPDATE NO ACTION;

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
  ADD CONSTRAINT `fk_user_rol1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `users_persona_id_persona_fk` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`);

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_venta_persona1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
