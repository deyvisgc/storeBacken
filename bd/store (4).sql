-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-03-2021 a las 09:25:48
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
            insert into product (pro_name, pro_precio_compra,pro_cantidad, pro_cantidad_min, pro_status, pro_cod_barra,fecha_creacion)
            values (in_pro_nombre,in_precio_compra,in_cantidad,in_cantidad_minima,'active',in_codeBarra, now());
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `autoInc` (`name` VARCHAR(10))  BEGIN
        DECLARE getCount INT(10);
        DECLARE getCount1 varchar(10);
        SET getCount = ( SELECT COUNT(test_id) FROM tests);
        SET getCount1 = (concat('P', (LPAD(getCount, 5, '0'))));
        INSERT INTO tests (test_num, test_name) VALUES (getCount1, name);
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `id_caja` int(11) NOT NULL,
  `ca_name` varchar(250) NOT NULL,
  `ca_description` varchar(45) DEFAULT NULL,
  `ca_status` varchar(150) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja_historial`
--

CREATE TABLE `caja_historial` (
  `id_caja_historial` int(11) NOT NULL,
  `ch_fecha_operacion` datetime NOT NULL,
  `ch_tipo_operacion` varchar(150) NOT NULL,
  `ch_total_dinero` double(15,2) NOT NULL,
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
(196, 79, 4, 1, 1, NULL, '22.00', '22.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clase_producto`
--

CREATE TABLE `clase_producto` (
  `id_clase_producto` int(11) NOT NULL,
  `clas_name` varchar(250) NOT NULL,
  `clas_id_clase_superior` int(11) NOT NULL,
  `clas_status` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `clase_producto`
--

INSERT INTO `clase_producto` (`id_clase_producto`, `clas_name`, `clas_id_clase_superior`, `clas_status`) VALUES
(10, 'BEBIDAS', 0, 'active'),
(11, 'Gaseosa', 10, 'active'),
(12, 'AGUAS', 10, 'active'),
(13, 'Cervezas', 10, 'disable'),
(14, 'Serial', 0, 'disable'),
(15, 'Arroz', 14, 'disable');

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
  `comFecha` date DEFAULT NULL,
  `comEstado` int(11) DEFAULT NULL,
  `comSerieComprobante` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ESTADO CREDITO : 1 debe, 2: completado o pagado; comEstado: 1  viegente, 0 anuladas';

--
-- Volcado de datos para la tabla `compra`
--

INSERT INTO `compra` (`idCompra`, `idProveedor`, `comTipoComprobante`, `comSerieCorrelativo`, `comTipoPago`, `comUrlComprobante`, `comDescuento`, `comEstadoTipoPago`, `comSubTotal`, `comTotal`, `comMontoDeuda`, `comMontoPagado`, `comIgv`, `com_cuotas`, `comFecha`, `comEstado`, `comSerieComprobante`) VALUES
(12, 2, 'factura', 'C000012', 'credito', NULL, NULL, 1, 2258.69, 2665.25, '665.25', '2000.00', 406.56, 3, '2021-03-27', 1, 'F000001'),
(13, 2, 'boleta', 'C000013', 'credito', 'http://localhost:8000/storage/app/Comprobantes/3f104f95-c3ee-4126-8a4c-1757acfcf354_1616813540.pdf', NULL, 1, 1942.16, 2291.75, '291.75', '2000.00', 349.59, 4, '2021-03-27', 1, 'B000001'),
(14, 2, 'factura', 'C000014', 'credito', NULL, NULL, 1, 578.39, 682.50, '182.50', '500.00', 104.11, 3, '2021-03-27', 0, 'F000013'),
(15, 2, 'boleta', 'C000015', 'credito', NULL, NULL, 1, 840.68, 992.00, '392.00', '600.00', 151.32, 4, '2021-03-27', 0, 'B000014');

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
(17, 10, 24.00, 578.39, 14, 78),
(18, 10, 22.00, 578.39, 14, 77),
(19, 10, 22.00, 578.39, 14, 79);

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
(20, '0.50', '0.50', '2021-03-24 05:05:10', 2, 6, NULL, '0.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lote`
--

CREATE TABLE `lote` (
  `id_lote` int(11) NOT NULL,
  `lot_name` varchar(250) NOT NULL,
  `lot_status` varchar(250) NOT NULL,
  `lot_codigo` varchar(250) NOT NULL,
  `lot_expiration_date` timestamp NULL DEFAULT NULL,
  `lot_creation_date` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `lote`
--

INSERT INTO `lote` (`id_lote`, `lot_name`, `lot_status`, `lot_codigo`, `lot_expiration_date`, `lot_creation_date`) VALUES
(10, 'KILOSs', 'active', 'P000000', '2021-03-13 15:27:49', '2021-02-13 15:27:49'),
(11, 'AGUAs', 'active', 'P0000022', '2021-03-15 23:42:24', '2021-02-15 23:42:24'),
(12, 'KILOGRAMO', 'active', 'P000000', '2021-02-16 00:00:00', '2021-02-10 00:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `id_persona` int(11) NOT NULL,
  `per_nombre` varchar(250) NOT NULL,
  `per_apellido` varchar(250) NOT NULL,
  `per_direccion` varchar(250) DEFAULT NULL,
  `per_celular` varchar(250) DEFAULT NULL,
  `id_user` int(11) NOT NULL,
  `per_tipo` varchar(150) NOT NULL,
  `per_dni` varchar(8) DEFAULT NULL,
  `per_razon_social` text DEFAULT NULL,
  `per_ruc` varchar(11) DEFAULT NULL,
  `per_status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`id_persona`, `per_nombre`, `per_apellido`, `per_direccion`, `per_celular`, `id_user`, `per_tipo`, `per_dni`, `per_razon_social`, `per_ruc`, `per_status`) VALUES
(2, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos garcua', '12345678977', 'active'),
(3, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos cercado', '12345678976', 'active'),
(4, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos flores', '12345678975', 'active'),
(5, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes', '12345678973', 'active'),
(6, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores', '12345678972', 'active'),
(7, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 1', '12345678971', 'active'),
(8, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 2', '12345678972', 'active'),
(9, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos cercado 2', '12345678960', 'active'),
(10, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos flores 3', '12345678951', 'active'),
(11, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 1', '12345678945', 'active'),
(12, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 8', '12345678932', 'active'),
(13, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 2', '12345678962', 'active'),
(14, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 6', '12345678971', 'active'),
(15, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos cercado 4', '12345678910', 'active'),
(16, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos floress', '12345678975', 'active'),
(17, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes10', '12345678921', 'active'),
(18, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores10', '12345678922', 'active'),
(19, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 512', '12345678998', 'active'),
(20, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 522', '12345678999', 'active'),
(21, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos garcua', '12345678977', 'active'),
(22, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos cercado', '12345678976', 'active'),
(23, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos flores', '12345678975', 'active'),
(24, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes', '12345678973', 'active'),
(25, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores', '12345678972', 'active'),
(26, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 1', '12345678971', 'active'),
(27, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 2', '12345678972', 'active'),
(28, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos cercado 2', '12345678960', 'active'),
(29, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos flores 3', '12345678951', 'active'),
(30, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 1', '12345678945', 'active'),
(31, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 8', '12345678932', 'active'),
(32, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 2', '12345678962', 'active'),
(33, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 6', '12345678971', 'active'),
(34, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos cercado 4', '12345678910', 'active'),
(35, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos floress', '12345678975', 'active'),
(36, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes10', '12345678921', 'active'),
(37, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores10', '12345678922', 'active'),
(38, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los pulipanes 512', '12345678998', 'active'),
(39, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'los soles flores 522', '12345678999', 'active');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `privilegio`
--

CREATE TABLE `privilegio` (
  `id_privilegio` int(11) NOT NULL,
  `pri_nombre` varchar(250) NOT NULL,
  `pri_acces` varchar(250) NOT NULL,
  `pri_group` varchar(200) NOT NULL,
  `pri_orden` int(11) NOT NULL,
  `pri_status` varchar(150) NOT NULL,
  `pri_ico` varchar(200) NOT NULL,
  `pri_ico_group` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `product`
--

CREATE TABLE `product` (
  `id_product` int(11) NOT NULL,
  `pro_name` varchar(250) DEFAULT NULL,
  `pro_precio_compra` decimal(15,2) DEFAULT NULL,
  `pro_precio_venta` decimal(15,2) DEFAULT NULL,
  `pro_cantidad` int(11) DEFAULT NULL,
  `pro_cantidad_min` int(11) DEFAULT NULL,
  `pro_status` varchar(150) DEFAULT NULL,
  `pro_description` varchar(250) DEFAULT NULL,
  `id_lote` int(11) DEFAULT NULL,
  `id_clase_producto` int(11) DEFAULT NULL,
  `id_unidad_medida` int(11) DEFAULT NULL,
  `pro_cod_barra` varchar(100) DEFAULT NULL,
  `pro_code` varchar(10) DEFAULT NULL,
  `id_subclase` int(11) DEFAULT NULL,
  `fecha_creacion` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product`
--

INSERT INTO `product` (`id_product`, `pro_name`, `pro_precio_compra`, `pro_precio_venta`, `pro_cantidad`, `pro_cantidad_min`, `pro_status`, `pro_description`, `id_lote`, `id_clase_producto`, `id_unidad_medida`, `pro_cod_barra`, `pro_code`, `id_subclase`, `fecha_creacion`) VALUES
(76, 'GASEOSA', '24.25', '33.00', 80, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11, NULL),
(77, 'CHOCOLATE', '22.00', '33.00', 68, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15, NULL),
(78, 'Arroz', '24.25', '33.00', 33, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11, NULL),
(79, 'Azucar', '22.00', '33.00', 41, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15, NULL),
(80, 'Menestras', '24.25', '33.00', 23, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11, NULL),
(81, 'Pollo', '22.00', '33.00', 11, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15, NULL),
(82, 'Pato', '24.25', '33.00', 8, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11, NULL),
(83, 'Pan', '22.00', '33.00', 4, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15, NULL),
(96, 'Huevo', '100.00', NULL, 20, 1, 'active', NULL, NULL, NULL, NULL, '77582030031796', NULL, NULL, '2021-03-21 05:53:24'),
(127, 'ATUM', '234.30', NULL, 40, 10, 'active', NULL, NULL, NULL, NULL, '77582030031797', 'P0127', NULL, '2021-03-21 14:47:24'),
(128, 'Cerveza', '393.00', NULL, 58, 39, 'active', NULL, NULL, NULL, NULL, '775820300317128', 'P0128', NULL, '2021-03-21 14:48:17'),
(129, 'nenene', '222.00', NULL, 24, 122, 'active', NULL, NULL, NULL, NULL, '775820300317129', 'P0129', NULL, '2021-03-21 14:49:53'),
(130, 'nenenen', '22.00', NULL, 2, 1, 'active', NULL, NULL, NULL, NULL, '775820300317130', 'P0130', NULL, '2021-03-21 14:53:37');

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
(1, 'Admin', 'active');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol_has_privilegio`
--

CREATE TABLE `rol_has_privilegio` (
  `idrol_has_privilegio` int(11) NOT NULL,
  `id_privilegio` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sangria`
--

CREATE TABLE `sangria` (
  `id_sangria` int(11) NOT NULL,
  `san_monto` double(15,2) NOT NULL,
  `san_fecha` datetime NOT NULL,
  `san_tipo_sangria` varchar(150) NOT NULL,
  `san_motivo` varchar(250) NOT NULL,
  `id_caja` int(11) NOT NULL,
  `id_user` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad_medida`
--

CREATE TABLE `unidad_medida` (
  `id_unidad_medida` int(11) NOT NULL,
  `um_name` varchar(250) NOT NULL,
  `um_nombre_corto` varchar(250) NOT NULL,
  `um_status` varchar(150) NOT NULL,
  `um_fecha_creacion` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `unidad_medida`
--

INSERT INTO `unidad_medida` (`id_unidad_medida`, `um_name`, `um_nombre_corto`, `um_status`, `um_fecha_creacion`) VALUES
(9, 'DEYVIS', 'P000002', 'active', '2021-02-15 22:45:22'),
(10, 'PESO', 'P000002', 'active', '2021-02-15 23:00:53');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

CREATE TABLE `user` (
  `id_user` int(11) NOT NULL,
  `us_name` varchar(250) NOT NULL,
  `us_passwor` varchar(250) NOT NULL,
  `us_status` varchar(150) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `us_token` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id_user`, `us_name`, `us_passwor`, `us_status`, `id_rol`, `us_token`) VALUES
(2, 'deyvis', '33', 'active', 1, 'asasasa');

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
  `ven_tipo_venta` varchar(250) NOT NULL,
  `ven_codigo` varchar(250) NOT NULL,
  `ven_tipo_pago` varchar(250) NOT NULL,
  `id_persona` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`id_caja`),
  ADD KEY `fk_caja_user1_idx` (`id_user`);

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
-- Indices de la tabla `lote`
--
ALTER TABLE `lote`
  ADD PRIMARY KEY (`id_lote`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`id_persona`),
  ADD KEY `fk_persona_user1_idx` (`id_user`);

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
  ADD KEY `fk_product_lote1_idx` (`id_lote`),
  ADD KEY `fk_product_clase_producto1_idx` (`id_clase_producto`),
  ADD KEY `fk_product_unidad_medida1_idx` (`id_unidad_medida`);

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
-- Indices de la tabla `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
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
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `id_caja` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `caja_historial`
--
ALTER TABLE `caja_historial`
  MODIFY `id_caja_historial` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `carrito`
--
ALTER TABLE `carrito`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=197;

--
-- AUTO_INCREMENT de la tabla `clase_producto`
--
ALTER TABLE `clase_producto`
  MODIFY `id_clase_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `idCompra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `idCompraDetalle` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `lote`
--
ALTER TABLE `lote`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  MODIFY `id_privilegio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=131;

--
-- AUTO_INCREMENT de la tabla `registro_sanitario`
--
ALTER TABLE `registro_sanitario`
  MODIFY `id_registro_sanitario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `rol_has_privilegio`
--
ALTER TABLE `rol_has_privilegio`
  MODIFY `idrol_has_privilegio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sangria`
--
ALTER TABLE `sangria`
  MODIFY `id_sangria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `unidad_medida`
--
ALTER TABLE `unidad_medida`
  MODIFY `id_unidad_medida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
  ADD CONSTRAINT `fk_caja_user1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `caja_historial`
--
ALTER TABLE `caja_historial`
  ADD CONSTRAINT `fk_caja_historial_caja1` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_caja_historial_user1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
  ADD CONSTRAINT `fk_persona_user1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `fk_product_clase_producto1` FOREIGN KEY (`id_clase_producto`) REFERENCES `clase_producto` (`id_clase_producto`),
  ADD CONSTRAINT `fk_product_lote1` FOREIGN KEY (`id_lote`) REFERENCES `lote` (`id_lote`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_product_unidad_medida1` FOREIGN KEY (`id_unidad_medida`) REFERENCES `unidad_medida` (`id_unidad_medida`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `rol_has_privilegio`
--
ALTER TABLE `rol_has_privilegio`
  ADD CONSTRAINT `fk_rol_has_privilegio_privilegio` FOREIGN KEY (`id_privilegio`) REFERENCES `privilegio` (`id_privilegio`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_rol_has_privilegio_rol1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `sangria`
--
ALTER TABLE `sangria`
  ADD CONSTRAINT `fk_sangria_caja1` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_sangria_user1` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `fk_user_rol1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `fk_venta_persona1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE NO ACTION ON UPDATE NO ACTION;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;


--por correr
--19/08/2021
create table unidad_medida
(
    id_unidad_medida  int auto_increment
        primary key,
    um_name           varchar(50) not null,
    um_status         varchar(20) not null,
    um_fecha_creacion timestamp   null,
    um_code           varchar(10) null
)
    charset = utf8;
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (1, 'BOBINAS', 'active', '2021-08-19 07:59:08', '4A');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (2, 'BALDE', 'active', '2021-08-19 07:59:33', 'BJ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (3, 'BARRILES', 'active', '2021-08-19 07:59:54', 'BLL');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (4, 'BOLSA', 'active', '2021-08-19 08:00:07', 'BG');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (5, 'BOTELLAS', 'active', '2021-08-19 08:00:30', 'BO');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (6, 'CAJA', 'active', '2021-08-19 08:00:57', 'BX');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (7, 'CARTONES', 'active', '2021-08-19 08:01:15', 'CT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (8, 'CENTIMETRO CUADRADO', 'active', '2021-08-19 08:01:40', 'CMK');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (9, 'CENTIMETRO CUBICO', 'active', '2021-08-19 08:01:56', 'CMQ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (10, 'CENTIMETRO LINEAL', 'active', '2021-08-19 08:02:25', 'CMT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (11, 'CIENTO DE UNIDADES', 'active', '2021-08-19 08:02:40', 'CEN');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (12, 'CILINDRO', 'active', '2021-08-19 08:02:59', 'CY');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (13, 'CONOS', 'active', '2021-08-19 08:03:21', 'CJ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (14, 'DOCENA', 'active', '2021-08-19 08:03:47', 'DZN');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (15, 'DOCENA POR 10**6', 'active', '2021-08-19 08:04:22', 'DZP');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (16, 'FARDO', 'active', '2021-08-19 08:04:36', 'BE');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (17, 'GALON INGLES (4,545956L)', 'active', '2021-08-19 08:04:55', 'GLI');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (18, 'GRAMO', 'active', '2021-08-19 08:05:17', 'GRM');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (19, 'GRUESA', 'active', '2021-08-19 08:05:30', 'GRO');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (20, 'HECTOLITRO', 'active', '2021-08-19 08:05:51', 'HLT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (21, 'HOJA
', 'active', '2021-08-19 08:06:16', 'LEF');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (22, 'JUEGO', 'active', '2021-08-19 08:07:57', 'SET');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (23, 'KILOGRAMO
', 'active', '2021-08-19 08:08:16', 'KGM');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (24, 'KILOMETRO', 'active', '2021-08-19 08:08:33', 'KTM');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (25, 'KILOVATIO HORA', 'active', '2021-08-19 08:08:54', 'KWH');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (26, 'KIT', 'active', '2021-08-19 08:09:21', 'KT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (27, 'LATAS', 'active', '2021-08-19 08:09:33', 'CA');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (28, 'LIBRAS', 'active', '2021-08-19 08:09:58', 'LBR');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (29, 'LITRO', 'active', '2021-08-19 08:10:16', 'LTR');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (30, 'MEGAWATT HORA', 'active', '2021-08-19 08:10:35', 'MWH');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (31, 'METRO', 'active', '2021-08-19 08:10:55', 'MTR');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (32, 'METRO CUADRADO
', 'active', '2021-08-19 08:11:16', 'MTK');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (33, 'METRO CUBICO', 'active', '2021-08-19 08:11:32', 'MTQ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (34, 'MILIGRAMOS', 'active', '2021-08-19 08:11:49', 'MGM');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (35, 'MILILITRO', 'active', '2021-08-19 08:12:07', 'MLT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (36, 'MILIMETRO', 'active', '2021-08-19 08:12:20', 'MMT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (37, 'MILIMETRO CUADRADO', 'active', '2021-08-19 08:12:41', 'MMK');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (38, 'MILIMETRO CUBICO', 'active', '2021-08-19 08:12:59', 'MMQ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (39, 'MILLARES
', 'active', '2021-08-19 08:13:14', 'MLL');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (40, 'MILLON DE UNIDADES', 'active', '2021-08-19 08:13:33', 'UM');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (41, 'ONZAS', 'active', '2021-08-19 08:13:53', 'ONZ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (42, 'PALETAS', 'active', '2021-08-19 08:14:08', 'PF');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (43, 'PAQUETE
', 'active', '2021-08-19 08:14:29', 'PK');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (44, 'PAR', 'active', '2021-08-19 08:14:51', 'PR');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (45, 'PIES', 'active', '2021-08-19 08:15:05', 'FOT');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (46, 'PIES CUADRADOS', 'active', '2021-08-19 08:15:20', 'FTK');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (47, 'PIES CUBICOS', 'active', '2021-08-19 08:15:37', 'FTQ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (48, 'PIEZAS', 'active', '2021-08-19 08:15:52', 'C62');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (49, 'PLACAS', 'active', '2021-08-19 08:16:10', 'PG');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (50, 'PLIEGO', 'active', '2021-08-19 08:16:27', 'ST');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (51, 'PULGADAS', 'active', '2021-08-19 08:16:49', 'INH');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (52, 'RESMA', 'active', '2021-08-19 08:17:07', 'RM');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (53, 'TAMBOR', 'active', '2021-08-19 08:17:34', 'DR');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (54, 'TONELADA CORTA', 'active', '2021-08-19 08:17:58', 'STN');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (55, 'TONELADA LARGA', 'active', '2021-08-19 08:18:14', 'LTN');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (56, 'TONELADAS', 'active', '2021-08-19 08:18:28', 'TNE');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (57, 'TUBOS', 'active', '2021-08-19 08:18:48', 'TU');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (58, 'UNIDAD (BIENES)', 'active', '2021-08-19 08:19:06', 'NIU');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (59, 'UNIDAD (SERVICIOS)', 'active', '2021-08-19 08:19:22', 'ZZ');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (60, 'US GALON (3,7843 L)', 'active', '2021-08-19 08:19:50', 'GLL');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (61, 'YARDA', 'active', '2021-08-19 08:20:05', 'YRD');
insert into sysventas.unidad_medida (id_unidad_medida, um_name, um_status, um_fecha_creacion, um_code) values (62, 'YARDA CUADRADA', 'active', '2021-08-19 08:20:31', 'YDK');

