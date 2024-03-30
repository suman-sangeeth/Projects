
-- cleaning data using sql queries

use portfolio_project;

select *
from Nashville_Housing;

--1. standardize date format --- timestamps at the end aren't required -- by changing data type

select SaleDate
from Nashville_Housing;

select SaleDate, CONVERT(Date,SaleDate)
from Nashville_Housing;

-- changing datatype of saledate to date
alter table Nashville_Housing
alter column SaleDate date;

---------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Populating property address data using self-join -- some addresses are null 

select *
from Nashville_Housing
order by ParcelID;

select nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress, isnull(nh1.PropertyAddress,nh2.PropertyAddress)
from Nashville_Housing nh1 
	join Nashville_Housing nh2 on nh1.ParcelID = nh2.ParcelID AND nh1.[UniqueID ] != nh2.[UniqueID ]
where nh1.PropertyAddress is null;

update nh1
set propertyaddress = isnull(nh1.PropertyAddress,nh2.PropertyAddress)
from Nashville_Housing nh1 
	join Nashville_Housing nh2 on nh1.ParcelID = nh2.ParcelID AND nh1.[UniqueID ] != nh2.[UniqueID ]
where nh1.PropertyAddress is null;


-----------------------------------------------------------------------------------------------------------------------------------------

-- 3a.Breaking out Address into Individual Columns (Address, City, State) -- some have adddress+city+state in one cell -- using substring

select PropertyAddress
from Nashville_Housing;

select substring(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	   substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as City
from Nashville_Housing;

alter table Nashville_Housing
add PropertySplitAddress Nvarchar(255);

alter table Nashville_Housing
add PropertySplitCity Nvarchar(255);

update Nashville_Housing
set PropertySplitAddress = substring(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1);

update Nashville_Housing
set PropertySplitCity =  substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress));


-- just checking the two
select PropertySplitAddress
from Nashville_Housing
where PropertySplitAddress like '%,%';

select PropertySplitCity
from Nashville_Housing
where PropertySplitCity like '%,%';



select *
from Nashville_Housing;

--3b. editing owner address similarly --- using parsename

select OwnerAddress
from Nashville_Housing;

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from Nashville_Housing

alter table Nashville_Housing
add OwnerSplitAddress Nvarchar(255);

alter table Nashville_Housing
add OwnerSplitCity Nvarchar(255);

alter table Nashville_Housing
add OwnerSplitState Nvarchar(255);

update Nashville_Housing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3);

update Nashville_Housing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2);

update Nashville_Housing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1);


-------------------------------------------------------------------------------------------------------------------------------------

-- 4.  Change Y and N to Yes and No in "Sold as Vacant" field  -- using case statement

Select distinct SoldAsVacant, count(SoldAsVacant)
from Nashville_Housing
group by SoldAsVacant
order by 2;

Select  SoldAsVacant,
		case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
		end
from Nashville_Housing;

update Nashville_Housing
set SoldAsVacant = case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
		end;


------------------------------------------------------------------------------------------------------------------------------------------

-- 5.  Remove Duplicates -- using cte

with RowNum_cte as(
select *,	
	   ROW_NUMBER() OVER (PARTITION BY	ParcelID,
										PropertyAddress,
										SalePrice,
										SaleDate,
										LegalReference
						 ORDER BY UniqueID) as row_num
from Nashville_Housing
)

delete
from RowNum_cte
where row_num >1;


--------------------------------------------------------------------------------------------------------------------------------------

-- 6. delete unused columns

alter table Nashville_Housing
drop column OwnerAddress,PropertyAddress, TaxDistrict;

select *
from Nashville_Housing;














