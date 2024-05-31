/*
Ejercicio 01:
Crear una función que retorne el país de procedencia del cliente con la menor cantidad de pedidos atendidos para un determinado año.
Orders: year(OrderDate) (CustomerID), OrderID
Customers: Country (CustomerID)
*/

create view VOrdersQuantityByYearByCountry 
as
	select year(OrderDate) as Year, Country, count(OrderID) as Quantity
	from Orders as O
	  inner join Customers as C on O.CustomerID = C.CustomerID
	group by year(OrderDate), Country
go


create function FCountryWithMinOrdersQuantityByYear (@Year int) returns table
as
return select Country
		from VOrdersQuantityByYearByCountry
		where Year = @Year and Quantity = (select min(Quantity)
										from VOrdersQuantityByYearByCountry
										where Year = @Year)
go

/*
Ejercicio 02:
Crear una función que retorne el nombre de la categoría  de producto con la mayor
cantidad de ítems de productos vendidos para un determinado año.
Categories: CategoryName (CategoryID)
Products: (CategoryID) (ProductID)
OrderDetails: Quantity (ProductID) (OrderID)
Orders: Year(OrderDate) (OrderID)
*/
create view VItemsQuantityByCategoryByYear
as
	select CategoryName, Year(OrderDate) as Year, sum(Quantity) as Total
	from Categories as C
		inner join Products as P on C.CategoryID = P.CategoryID
		inner join [Order Details] as OD on P.ProductID = OD.ProductID
		inner join Orders as O on OD.OrderID = O.OrderID
	group by CategoryName, Year(OrderDate)
go

create function VCategoryWithMaxItemsQuantityByYear (@Year int) returns table
as
return
select CategoryName from VItemsQuantityByCategoryByYear
where year =@Year  and Total = (select max(Total) from VItemsQuantityByCategoryByYear
								where Year = @Year)
go

/*
Implemente un procedimiento almacenado que imprima cada uno de los registros de los productos indicando su nombre y unidades en stock, y al finalizar, imprima el total del inventario.
*/
create procedure SPInventory 
as
begin
	/* Paso 1: declarar el cursor */
	declare ProductsCursor cursor for
	select ProductName, UnitsInStock from Products

	/* Paso 2: abrir el cursor */
	open ProductsCursor

	/* Paso 3: declarar variables para cada uno de los datos de la consulta */
	declare @ProductName nvarchar(40)
	declare @Stock smallint

	declare @Total smallint
	set @Total = 0

	/* Paso 4: leer una fila */
	fetch ProductsCursor into @ProductName, @Stock

	while(@@fetch_status = 0)
	begin
		print @ProductName + ': ' + cast (@Stock as nvarchar(6))
		set @Total = @Total + @Stock
		fetch ProductsCursor into @ProductName, @Stock
	end

	print 'Inventario: ' + cast (@Total as nvarchar(6))

	/* Paso 5: cerrar el cursor */ 
	close ProductsCursor

	/* Paso 6: liberar los recursos utilizador por el cursor*/
	deallocate ProductsCursor
end
go

exec SPInventory
go

/*
Crear un procedimiento almacenado para insertar un nuevo cliente
*/

create procedure SPInsertCustomer
	@CustomerID nchar(5),
	@CompanyName nvarchar(40)
as
begin
	begin try
		begin transaction TInsert
			insert into Customers(CustomerID, CompanyName)
			values (@CustomerID, @CompanyName)
			print 'Se registró el cliente'
		commit
	end try
	begin catch
		if (@@TRANCOUNT > 0)
		begin
			print error_message()
			rollback
		end
	end catch	
end
go

/*
Crear un trigger para la operación delete de la tabla Customers
*/
create trigger TRICustomers on Customers
for delete
as
begin
	select * from deleted
	print 'Se eliminó un cliente'
end
go

delete from Customers where CustomerID = 'BBBBB'
go


