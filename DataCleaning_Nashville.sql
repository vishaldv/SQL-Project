--DATA CLEANING

--Standardising date format
select *
from PortfolioProject..Nashville_Housing

Update Nashville_Housing
set SaleDate=CONVERT(date,SaleDate)

alter table Nashville_Housing
add SaleDateConverted date;

update Nashville_Housing
set SaleDateConverted=CONVERT(date,SaleDate)

--Populating Property Address in columns where it shows null

select * 
from Nashville_Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] --(not equal -> <>)
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) --ISNULL -> if a.PrpAdd is null, insert contents of b.PrpAdd to a.Prp.Add)
from Nashville_Housing a
join Nashville_Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] --(not equal -> <>)
where a.PropertyAddress is null

--Seperating Address into seperate columns
select PropertyAddress
from Nashville_Housing
order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from Nashville_Housing
order by ParcelID
-- SUBSTRING(#1, #2, #3) 
-- #1 - column name                                   CHARINDEX(',',col_name) - gives a number, ie the position of 
-- #2 - start point (denotes position in number)                                 the ',' in the column name 
-- #3 - end point

alter table Nashville_Housing
add Property_Split_Address nvarchar(200);

Update Nashville_Housing
set Property_Split_Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table Nashville_Housing
add Property_Split_City nvarchar(200);

update Nashville_Housing
set Property_Split_City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
