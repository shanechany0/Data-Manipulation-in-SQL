-- Select all data
select *
from nashville_housing nh ;

--Change date format
select saledate, cast(saledate as date)
from nashville_housing nh ;

update nashville_housing 
set saledate = cast(saledate as date)

--Extract property address for empty PropertyAddress cells
select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,
case when a.propertyaddress = '' 
	then b.propertyaddress
	else a.propertyaddress
end as full_address
from nashville_housing a 
join nashville_housing b 
	on a.parcelid = b.parcelid 
	and a."UniqueID " <> b."UniqueID "
where a.propertyaddress = ''

--Split PropertyAddess to Address, City
select split_part(propertyaddress, ',', 1) as Address, split_part(propertyaddress, ',', 2) as City
from nashville_housing nh ;

--Add columns for Property Address, City
alter table nashville_housing 
add propertysplitaddress varchar(255);

update nashville_housing 
set propertysplitaddress = split_part(propertyaddress, ',', 1);

alter table nashville_housing 
add propertysplitcity varchar(255);

update nashville_housing 
set propertysplitcity = split_part(propertyaddress, ',', 2);

--Split OwnerAddress to Address, City, State
select split_part(owneraddress, ',', 1) as Address, split_part(owneraddress, ',', 2) as City, split_part(owneraddress, ',', 3)
from nashville_housing nh ;

--Add columns for Owner Address, City
alter table nashville_housing 
add ownersplitaddress varchar(255);

update nashville_housing 
set ownersplitaddress = split_part(owneraddress, ',', 1);

alter table nashville_housing 
add ownerssplitcity varchar(255);

update nashville_housing 
set ownerssplitcity = split_part(owneraddress, ',', 2);

alter table nashville_housing 
add ownersplitstate varchar(255);

update nashville_housing 
set ownersplitstate = split_part(owneraddress, ',', 3);

--Standardise Yes/No
select distinct(soldasvacant), count(*)
from nashville_housing nh 
group by soldasvacant ;

select soldasvacant, 
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant 
	 end
from nashville_housing nh ;

update nashville_housing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant 
	 end;
	
select distinct soldasvacant 
from nashville_housing nh ;

-- Remove duplicates
with t1 as
(
select *, row_number () over (partition by parcelid, propertyaddress, saleprice, legalreference order by "UniqueID ") as row_num
from nashville_housing nh 
order by row_num desc
)
delete from nashville_housing nh2 
where "UniqueID " in (select "UniqueID " from t1 where row_num > 1)

-- Delete unused columns
alter table nashville_housing 
drop column owneraddress, 
drop column taxdistrict, 
drop column propertyaddress;





