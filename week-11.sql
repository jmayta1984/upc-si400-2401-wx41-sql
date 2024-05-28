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
