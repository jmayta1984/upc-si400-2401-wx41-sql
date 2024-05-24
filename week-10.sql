/*
Ejercicio 01:
Crear una función que retorne la cantidad total de pedidos
*/
create function FOrdersQuantity() returns int
as
begin
	return (select count(*) from Orders)
end
go

print dbo.FOrdersQuantity()
go

select dbo.FOrdersQuantity() as Quantity
go
/*
Ejercicio 02:
Crear una función que retorne la cantidad de pedidos realizados para un determinado año
ingresado como parámetro.
*/
create function FOrdersQuantityByYear(@Year int) returns int
as
begin
	return (select count(Year(OrderDate))
			from Orders
			where Year(OrderDate) = @Year)
end
go

print dbo.FOrdersQuantityByYear(2015)
go

/*
Ejercicio 03:
Crear una función que retorne la cantidad total de artículos vendidos en un determinado año.
Orders Details: Quantity
*/
create function FItemsQuantityByYear(@Year int) returns int
as
begin
	declare @Total int
	set @Total = (	select sum(Quantity)
					from [Order Details] as OD
						inner join Orders as O on OD.OrderID = O.OrderID
					where  Year(OrderDate) = @Year)
	if (@Total is null) 
	begin
		set @Total = 0
	end
	return @Total

end

go

/*
Ejercicio 04:
Crear una función donde ingrese el nombre del país de destino del pedido y
retorne el total de las unidades vendidas.
*/

create function FItemsQuantityByCountry(@Country nvarchar(15)) returns int
as
begin
	declare @Total int
	set @Total = (	select sum(Quantity)
					from [Order Details] as OD
						inner join Orders as O on OD.OrderID = O.OrderID
					where ShipCountry = @Country)
	if (@Total is null) 
	begin
		set @Total = 0
	end
	return @Total

end
go
print dbo.FItemsQuantityByCountry('France')
go
/*
Ejercicio 05:
Crear una función que retorne los clientes que realizaron pedidos en un determinado año
ingresado como parámetro. Para cada cliente debe mostrar el código y nombre.
*/
create function FCustomersWithOrdersByYear(@Year int) returns table
as
return  (select distinct C.CustomerID, CompanyName
		from Customers as C
				inner join Orders as O on C.CustomerID  = O.CustomerID
		where Year(OrderDate) = @Year)
go

select * from dbo.FCustomersWithOrdersByYear(2018)
go
/*
Ejercicio 06:
Crear un procedimiento almacenado que permitar registrar
los datos de un cliente.
*/

create procedure SPInsertCustomer
	@CustomerID nchar(5),
	@CompanyName nvarchar(40)
as
begin
	insert into Customers (CustomerID, CompanyName)
		values (@CustomerID, @CompanyName)
end
go

exec SPInsertCustomer 'WOWIL', 'Willy Wonka'
go
select * from Customers where CustomerID = 'WOWIL'
