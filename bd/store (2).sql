-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-03-2021 a las 14:29:07
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `addCarrCompra` (IN `in_cantidad` INT, IN `in_precio_compra` DECIMAL(15,2), IN `in_idProducto` INT, IN `in_idPersona` INT, IN `in_idCaja` INT)  begin
    declare subtotalCompra decimal(15,2);
    declare cantidad_update decimal(15,2);
    IF EXISTS(select * from carrito where idProducto = in_idProducto and idPersona = in_idPersona) THEN
     update carrito set cantidad = cantidad + in_cantidad, precio =
     in_precio_compra where idProducto = in_idProducto and idPersona = in_idPersona;
     update product set pro_precio_compra= in_precio_compra where id_product= in_idProducto;
     select cantidad into cantidad_update from carrito where idProducto = in_idProducto;
     set subtotalCompra = cantidad_update* in_precio_compra;
     update carrito set  subTotal = subtotalCompra where idProducto = in_idProducto and idPersona = in_idPersona;
     ELSE
        set subtotalCompra = in_cantidad* in_precio_compra;
       insert into carrito(idProducto, idPersona, idCaja, cantidad, subTotal,precio)
       values (
       in_idProducto,
       in_idPersona,
       in_idCaja,
       in_cantidad,
       subtotalCompra,
       in_precio_compra
       );
   end if;
    select car.id,car.idProducto,car.idPersona,car.idCaja,car.cantidad,car.precio,car.subTotal, pro.pro_name, per.per_razon_social,totales.total
                                 from ((select sum(carrito.subTotal) as total from carrito where idPersona = in_idPersona)) totales,
                                 carrito as car, product as pro,
                                 persona as per where
                                 car.idProducto= pro.id_product and
                                 car.idPersona = per.id_persona and
                                 car.idPersona = in_idPersona group by car.id,car.idProducto,car.idPersona,car.idCaja,car.cantidad,car.precio, car.subTotal,pro.pro_name, per.per_razon_social;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `addCompra` (IN `in_subtotal` DECIMAL(15,2), IN `in_total` DECIMAL(15,2), IN `in_igv` DECIMAL(15,2), IN `in_tipoComprobante` VARCHAR(20), IN `in_tipoPago` VARCHAR(20), IN `in_idProveedor` INT)  begin
    DECLARE in_idproducto int;
    DECLARE in_cantidad int;
    DECLARE in_precio int;
    DECLARE in_id_compra int;
    DECLARE in_subtotalCarr decimal(15,2);
    DECLARE in_idDetalle int;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cursor_temp CURSOR FOR
    SELECT idProducto,cantidad,precio, subTotal from carrito WHERE carrito.idPersona=in_idProveedor;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  INSERT INTO compra(
 com_sub_total,
 com_total,
 com_igv,
 com_fecha,
 com_tipo_comprobante,
 com_tipo_pago,
 idProveedor
 )
 values(
 in_subtotal,
 in_total,
 in_igv,
 now(),
 in_tipoComprobante,
 in_tipoPago,
 in_idProveedor
 );
  SET in_id_compra = LAST_INSERT_ID();
   OPEN cursor_temp;
    read_loop: LOOP
    FETCH cursor_temp INTO in_idproducto,in_cantidad,in_precio,in_subtotalCarr;
    IF done THEN
        LEAVE read_loop;
    END IF;
    insert into detalle_compra(dc_cantidad, dc_precio_unitario, dc_sub_total, id_compra, id_product)
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
  `id_compra` int(11) NOT NULL,
  `com_sub_total` double(15,2) NOT NULL,
  `com_total` double(15,2) NOT NULL,
  `com_igv` double(15,2) NOT NULL,
  `com_fecha` datetime NOT NULL,
  `com_tipo_comprobante` varchar(250) NOT NULL,
  `com_serie_correlativo` varchar(250) DEFAULT NULL,
  `com_tipo_pago` varchar(10) DEFAULT NULL,
  `idProveedor` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `compra`
--

INSERT INTO `compra` (`id_compra`, `com_sub_total`, `com_total`, `com_igv`, `com_fecha`, `com_tipo_comprobante`, `com_serie_correlativo`, `com_tipo_pago`, `idProveedor`) VALUES
(53, 507.63, 599.00, 91.37, '2021-03-19 11:26:40', '\'factura\'', NULL, '\' debito\'', 2),
(54, 59.75, 70.50, 10.75, '2021-03-19 11:30:08', '\'boleta\'', NULL, '\' contado\'', 2),
(55, 39.19, 46.25, 7.05, '2021-03-19 11:31:54', '\'boleta\'', NULL, '\' debito\'', 2),
(56, 39.19, 46.25, 7.05, '2021-03-19 11:31:54', '\'boleta\'', NULL, '\' debito\'', 2),
(57, 714.62, 843.25, 128.63, '2021-03-19 11:33:27', '\'boleta\'', NULL, '\' credito\'', 2),
(58, 468.01, 552.25, 84.24, '2021-03-19 11:35:45', '\'boleta\'', NULL, '\' contado\'', 2),
(59, 141.95, 167.50, 25.55, '2021-03-19 13:27:35', '\'boleta\'', NULL, '\' credito\'', 2);

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
  `id_detalle_compra` int(11) NOT NULL,
  `dc_cantidad` int(11) NOT NULL,
  `dc_precio_unitario` double(15,2) NOT NULL,
  `dc_sub_total` double(15,2) NOT NULL,
  `id_compra` int(11) NOT NULL,
  `id_product` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `detalle_compra`
--

INSERT INTO `detalle_compra` (`id_detalle_compra`, `dc_cantidad`, `dc_precio_unitario`, `dc_sub_total`, `id_compra`, `id_product`) VALUES
(26, 14, 22.00, 507.63, 53, 77),
(27, 12, 24.00, 507.63, 53, 76),
(28, 1, 22.00, 59.75, 54, 77),
(29, 2, 24.00, 59.75, 54, 78),
(30, 1, 22.00, 39.19, 55, 77),
(31, 1, 24.00, 39.19, 55, 80),
(32, 12, 22.00, 714.62, 57, 79),
(33, 1, 24.00, 714.62, 57, 80),
(34, 12, 22.00, 714.62, 57, 77),
(35, 12, 24.00, 714.62, 57, 82),
(36, 12, 22.00, 468.01, 58, 79),
(37, 1, 24.00, 468.01, 58, 82),
(38, 12, 22.00, 468.01, 58, 81),
(39, 3, 24.00, 141.95, 59, 78),
(40, 1, 24.00, 141.95, 59, 80),
(41, 1, 24.00, 141.95, 59, 76),
(42, 1, 22.00, 141.95, 59, 83),
(43, 1, 24.00, 141.95, 59, 82);

--
-- Disparadores `detalle_compra`
--
DELIMITER $$
CREATE TRIGGER `aumentarStock` AFTER INSERT ON `detalle_compra` FOR EACH ROW Update product
set product.pro_cantidad = product.pro_cantidad + NEW.dc_cantidad
where product.id_product = NEW.id_product
$$
DELIMITER ;

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
(2, 'deyvis', 'garcia cercado', NULL, NULL, 2, 'proveedor', '48762828', 'hermanos garcua', '12345678977', 'active');

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
  `pro_name` varchar(250) NOT NULL,
  `pro_precio_compra` decimal(15,2) NOT NULL,
  `pro_precio_venta` decimal(15,2) NOT NULL,
  `pro_cantidad` int(11) NOT NULL,
  `pro_cantidad_min` int(11) NOT NULL,
  `pro_status` varchar(150) NOT NULL,
  `pro_description` varchar(250) DEFAULT NULL,
  `id_lote` int(11) NOT NULL,
  `id_clase_producto` int(11) NOT NULL,
  `id_unidad_medida` int(11) NOT NULL,
  `pro_cod_barra` varchar(100) DEFAULT NULL,
  `pro_code` varchar(10) DEFAULT NULL,
  `id_subclase` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `product`
--

INSERT INTO `product` (`id_product`, `pro_name`, `pro_precio_compra`, `pro_precio_venta`, `pro_cantidad`, `pro_cantidad_min`, `pro_status`, `pro_description`, `id_lote`, `id_clase_producto`, `id_unidad_medida`, `pro_cod_barra`, `pro_code`, `id_subclase`) VALUES
(76, 'GASEOSA', '24.25', '33.00', 172, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11),
(77, 'CHOCOLATE', '22.00', '33.00', 1016, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15),
(78, 'Arroz', '24.25', '33.00', 293, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11),
(79, 'Azucar', '22.00', '33.00', 27, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15),
(80, 'Menestras', '24.25', '33.00', 54, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11),
(81, 'Pollo', '22.00', '33.00', 35, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15),
(82, 'Pato', '24.25', '33.00', 46, 12, 'active', 'ASASa', 11, 10, 10, '77582030031775', 'P0076', 11),
(83, 'Pan', '22.00', '33.00', 4, 33, 'active', 'ASASAs', 11, 14, 10, '77582030031776', 'P0077', 15);

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
  ADD PRIMARY KEY (`id_compra`);

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
  ADD PRIMARY KEY (`id_detalle_compra`),
  ADD KEY `fk_detalle_compra_compra1_idx` (`id_compra`),
  ADD KEY `fk_detalle_compra_product1_idx` (`id_product`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT de la tabla `clase_producto`
--
ALTER TABLE `clase_producto`
  MODIFY `id_clase_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `id_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT de la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  MODIFY `id_detalle_compra` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

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
-- AUTO_INCREMENT de la tabla `lote`
--
ALTER TABLE `lote`
  MODIFY `id_lote` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `privilegio`
--
ALTER TABLE `privilegio`
  MODIFY `id_privilegio` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

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
-- Filtros para la tabla `detalle_compra`
--
ALTER TABLE `detalle_compra`
  ADD CONSTRAINT `fk_detalle_compra_compra1` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_detalle_compra_product1` FOREIGN KEY (`id_product`) REFERENCES `product` (`id_product`) ON DELETE NO ACTION ON UPDATE NO ACTION;

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
  ADD CONSTRAINT `fk_product_clase_producto1` FOREIGN KEY (`id_clase_producto`) REFERENCES `clase_producto` (`id_clase_producto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
