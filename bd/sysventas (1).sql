-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-09-2021 a las 17:20:51
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
(2, 'Almacen General', 'Av-lima-peru', NULL, 'AL0001', 'active');

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
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `id_persona` int(11) NOT NULL,
  `per_nombre` varchar(250) DEFAULT NULL,
  `per_direccion` varchar(250) DEFAULT NULL,
  `per_celular` varchar(250) DEFAULT NULL,
  `per_tipo` varchar(150) NOT NULL,
  `per_razon_social` text DEFAULT NULL,
  `per_tipo_documento` varchar(10) DEFAULT NULL,
  `per_status` varchar(20) DEFAULT NULL,
  `per_numero_documento` varchar(20) DEFAULT NULL,
  `per_codigo` varchar(50) DEFAULT NULL,
  `per_email` varchar(50) DEFAULT NULL,
  `id_tipo_cliente_proveedor` int(11) NOT NULL,
  `codigoInterno` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`id_persona`, `per_nombre`, `per_direccion`, `per_celular`, `per_tipo`, `per_razon_social`, `per_tipo_documento`, `per_status`, `per_numero_documento`, `per_codigo`, `per_email`, `id_tipo_cliente_proveedor`, `codigoInterno`) VALUES
(132, 'deyvis Garcia Cercado', 'Av.Virgen de candelaria ', '928832212', 'usuario', NULL, 'dni', 'active', '48762828', NULL, NULL, 1, '');

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
(18, 'Actualizar Stock', '/Almacen/ajustar-stock', 'Almacen', 'active', 'fas fa-money-check-alt', 2),
(20, 'Nuevo', '/Compras/index', 'Compras', 'active', '', 6),
(21, 'Listado', '/Compras/historial', 'Compras', 'active', '', 6),
(22, 'crear venta', '/Ventas/index', 'Ventas', 'active', '', 7),
(23, 'Compras', '/Reportes/compras', 'Reportes', 'active', '', 9),
(24, 'Administrar Caja', '/Caja/administracion', 'Caja', 'active', '', 5),
(25, 'Historial Caja', '/Caja/historial', 'Caja', 'active', '', 5),
(26, 'Cuentas por Cobrar', '/Reportes/cuentas-cobrar', 'Reportes', 'active', '', 9),
(27, 'Cuentas por Pagar', '/Reportes/cuentas-pagar', 'Reportes', 'active', '', 9),
(28, 'Reporte Compras', '/Reportes/compras', 'Reportes', 'active', '', 9),
(29, 'Salvatore', '/Administracion/salvatore', 'Administracion', 'active', '', 1),
(30, 'Proveedores', '/Administracion/proveedores', 'Administracion', 'active', '', 1),
(31, 'Historial', '/Almacen/historial', 'Almacen', 'active', '', 2),
(32, 'Clientes', '/clientes', 'Clientes', 'active', 'fas fa-user-cog', 0),
(35, 'Nuevo Cliente', '/Clientes/nuevo-cliente', 'Clientes', 'active', '', 32),
(36, 'Tipo Cliente', '/Clientes/tipo-cliente', 'Clientes', 'active', '', 32);

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
(395, 'Tanques 1100 Ltr Rotoplas Color Arena', 'active', '', 73, 58, '', 'P0395', 80, NULL, '2021-09-03', 2, '2021-09-23', 42, '', '', 'soles', 50, 1, 1, 0, 1, '120.00', '320.00'),
(396, 'Lavaderos Rojos', 'active', 'Asasa', 73, 58, '', 'P0396', 80, NULL, '2021-09-04', 2, '2021-09-23', 42, '', '', 'soles', 100, 1, 1, 0, 1, '100.00', '300.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product_history`
--

CREATE TABLE `product_history` (
  `id` int(11) NOT NULL,
  `id_producto` int(11) DEFAULT NULL,
  `id_lote` int(11) DEFAULT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `fecha_creacion` date DEFAULT NULL,
  `stock_antiguo` int(11) DEFAULT NULL,
  `stock_nuevo` int(11) DEFAULT NULL,
  `almacen` int(11) DEFAULT NULL,
  `precio_compra` decimal(15,2) DEFAULT NULL,
  `precio_venta` decimal(15,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `product_history`
--

INSERT INTO `product_history` (`id`, `id_producto`, `id_lote`, `fecha_vencimiento`, `fecha_creacion`, `stock_antiguo`, `stock_nuevo`, `almacen`, `precio_compra`, `precio_venta`) VALUES
(4, 395, 42, '2021-09-04', '2021-09-05', 20, 50, 2, '30.00', '60.00'),
(5, 396, 42, '2021-09-22', '2021-09-05', 80, 100, 2, '90.00', '120.00'),
(6, 395, 42, '2021-09-22', '2021-09-05', 50, 50, 2, '100.00', '300.00');

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
(30, 30, 1),
(32, 31, 1),
(33, 35, 1),
(34, 36, 1);

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
  `estado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `tipo_cliente_proveedor`
--

INSERT INTO `tipo_cliente_proveedor` (`id`, `descripcion`, `estado`) VALUES
(1, 'Interno', 1);

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
(13, 'deyvisgc', '$2y$10$y76W0r.tIqm8QAk2iNBztOP/onXWATOrxMHJxw2ocHdpoXIwe2xfK', 'active', 1, 'WHhpRFlGSzhKdjF2R05MZ0lxM3REa2lHaG82MVpuOHEwcUVGaXBvNA==', 132, '{\"ciphertext\":\"StAkbKyB+vZ6Lkl33PJ20A==\",\"iv\":\"fd7fc47ce9503885e9e7a694fe96c049\",\"salt\":\"34f176290648fe72be3b2ab8c6e11eec4104fc3b042c83fc0ea91c761e8b29d5b78b30165d28a4ec9f9d2a95c23452c1a536509d08f92441456f536dd1a3f28d9279b3de60bbe7201e2f08eb9c00554bfe0d00d5b1163e58a6e0183b03dc3ea2d427d09991eab57b76ffcfac06975b7effe7835b632dbf4c66068b32c8152a038f386746584369fefa0eb0c6539960b8b1522e40c022b209d9459e6f1a1f3b4053a00f0ee7a66a2b8d0f235aad8a2df5261f5a57cdfeec2bab83f5c80e4f11f975526edcc2e283818ec69f18cbde27c0de236dbb5e0a63d3fb9eca256c5dd573447823c97dde9e6cd7d6f076b6d352f7adc4a3e647df11b7d5a41a78a968987e\"}'),
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
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`id_persona`),
  ADD KEY `tipo_cliente_proveedor_id` (`id_tipo_cliente_proveedor`);

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
-- AUTO_INCREMENT de la tabla `almacen`
--
ALTER TABLE `almacen`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  MODIFY `id_privilegio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=397;

--
-- AUTO_INCREMENT de la tabla `product_history`
--
ALTER TABLE `product_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `idrol_has_privilegio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `id_unidad_medida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

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
-- Filtros para la tabla `persona`
--
ALTER TABLE `persona`
  ADD CONSTRAINT `tipo_cliente_proveedor_id` FOREIGN KEY (`id_tipo_cliente_proveedor`) REFERENCES `tipo_cliente_proveedor` (`id`) ON UPDATE CASCADE;

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
