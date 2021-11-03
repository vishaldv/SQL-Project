--DATA CLEANING

--Standardising date format


select *
from PortfolioProject..Nashville_Housing

Update PortfolioProject..PortfolioProject..Nashville_Housing
set SaleDate=CONVERT(date,SaleDate)

alter table PortfolioProject..Nashville_Housing
add SaleDateConverted date;

update PortfolioProject..Nashville_Housing
set SaleDateConverted=CONVERT(date,SaleDate)



--Populating Property Address in columns where it shows null



select * 
from PortfolioProject..Nashville_Housing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..Nashville_Housing a
join PortfolioProject..Nashville_Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] --(not equal -> <>)
where a.PropertyAddress is null

update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) --ISNULL -> if a.PrpAdd is null, insert contents of b.PrpAdd to a.Prp.Add)
from PortfolioProject..Nashville_Housing a
join PortfolioProject..Nashville_Housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] --(not equal -> <>)
where a.PropertyAddress is null



--Seperating Address into seperate columns



select PropertyAddress
from PortfolioProject..Nashville_Housing
order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from PortfolioProject..Nashville_Housing
order by ParcelID
-- SUBSTRING(#1, #2, #3) 
-- #1 - column name                                   CHARINDEX(',',col_name) - gives a number, ie the position of 
-- #2 - start point (denotes position in number)                                 the ',' in the column name 
-- #3 - end point

alter table PortfolioProject..Nashville_Housing
add Property_Split_Address nvarchar(200);

Update PortfolioProject..Nashville_Housing
set Property_Split_Address=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject..Nashville_Housing
add Property_Split_City nvarchar(200);

update PortfolioProject..Nashville_Housing
set Property_Split_City=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))




--Seperating Owner address, city and state


select 
parsename(replace(OwnerAddress, ',', '.'),3) --replacing ',' to '.', as parsename works on '.' only
,parsename(replace(OwnerAddress, ',', '.'),2)
,parsename(replace(OwnerAddress, ',', '.'),1)
from PortfolioProject..Nashville_Housing

alter table PortfolioProject..Nashville_Housing
add Owner_Split_Address nvarchar(200);

Update PortfolioProject..Nashville_Housing
set Owner_Split_Address=parsename(replace(OwnerAddress, ',', '.'),3)

alter table PortfolioProject..Nashville_Housing
add Owner_Split_City nvarchar(200);

update PortfolioProject..Nashville_Housing
set Owner_Split_City=parsename(replace(OwnerAddress, ',', '.'),2)

alter table PortfolioProject..Nashville_Housing
add Owner_Split_State nvarchar(200);

update PortfolioProject..Nashville_Housing
set Owner_Split_State=parsename(replace(OwnerAddress, ',', '.'),1)

select * from PortfolioProject..Nashville_Housing



--Setting Y to Yes and N to No



select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..Nashville_Housing
group by SoldAsVacant
order by 2

select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..Nashville_Housing

update PortfolioProject..Nashville_Housing
set SoldAsVacant= CASE when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


--Removing duplicates


select *,
row_number() over (
partition by ParcelID,
			 SalePrice,
			 SaleDate,
			 LegalReference,
             PropertyAddress
			 order by UniqueID) row_num
from PortfolioProject..Nashville_Housing


with RowNum as (
select *,
row_number() over (
partition by ParcelID,
			 SalePrice,
			 SaleDate,
			 LegalReference,
             PropertyAddress
			 order by UniqueID) row_num
from PortfolioProject..Nashville_Housing

delete from RowNum
where row_num>1



--Deleting unimportant columns


select * from PortfolioProject..Nashville_Housing

alter table PortfolioProject..Nashville_Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate