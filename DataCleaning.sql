select * from PortfolioProject..NashvilleHousing


--standardize the date format
select SaleDate , SaleDateConverted, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

/*
alter table NashvilleHousing 
drop column SaleDate;

-- we can just drop the SaleDate column. But i'm keeping it in the dataset for now,
will delete all the unused columns together.
*/

-- Handling PropertyAddress column

select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


/* we can populate the address for the same ParcelID
For this we need to join the table to itself*/

select tab1.ParcelID,tab1.PropertyAddress,tab2.ParcelID,tab2.PropertyAddress,isnull(tab1.PropertyAddress,tab2.PropertyAddress)
from PortfolioProject..NashvilleHousing tab1
join PortfolioProject..NashvilleHousing tab2
on tab1.ParcelID=tab2.ParcelID
and tab1.[UniqueID ]<>tab2.[UniqueID ]
where tab1.PropertyAddress is null

update tab1
set PropertyAddress = isnull(tab1.PropertyAddress,tab2.PropertyAddress)
from PortfolioProject..NashvilleHousing tab1
join PortfolioProject..NashvilleHousing tab2
on tab1.ParcelID=tab2.ParcelID
and tab1.[UniqueID ]<>tab2.[UniqueID ]
where tab1.PropertyAddress is null

-- Lets break down the address column into Address, city

select PropertyAddress
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(100)


update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(100);
update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))



-- owner address
select OwnerAddress
from PortfolioProject..NashvilleHousing


select 
PARSENAME(replace(OwnerAddress,',','.'),3) ,
PARSENAME(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(100)

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(50)

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(20)

update PortfolioProject..NashvilleHousing
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

select * from PortfolioProject..NashvilleHousing

-- when we see our SoldAsVacant Column we see we have values like Yes,No,Y, and N(52-Y and 399-N)
-- We'll replace these Y and N to Yes and No

select Distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant=
case
	when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end



-- Remove Duplicates in the dataset

-- Let's first see all the duplicate entries we have in our table
with RowNumCTE as (
select *,
row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice, SaleDate,LegalReference
				 order by 
				 UniqueID
				 ) row_num
from PortfolioProject..NashvilleHousing
--order by row_num desc
)
select *
from RowNumCTE
where row_num>1
order by PropertyAddress

-- Deleting the duplicate entries in our table

with RowNumCTE as (
select *,
row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice, SaleDate,LegalReference
				 order by 
				 UniqueID
				 ) row_num
from PortfolioProject..NashvilleHousing
--order by row_num desc
)
delete
from RowNumCTE
where row_num>1


-- Delete unused columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress,TaxDistrict,propertyAddress,SaleDate
