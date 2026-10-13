select * from bankdata;

select * from bonddata;

select * from receiverdata;

select * from donordata;

-- 1. Find out how much donors spent on bond --

select sum(denominations) as total_money_spent from bonddata as a join donordata as b 
on a.unique_key=b.unique_key; 

-- 2. Find out total funds politicians got --

select sum(denominations) as total_fund_received from bonddata as a join receiverdata as b 
on a.unique_key=b.unique_key;

-- 3. Find out the total amount of unaccounted money received by parties (bonds without donors) --

select sum(denominations) as unaccounted_money from donordata as d right join 
receiverdata as r on d.unique_key=r.unique_key join bonddata as b on 
r.unique_key=b.unique_key where purchaser is null;

-- 4. Find year-wise how much money is spent on bonds --

select extract(year from d.purchasedate) as Year, sum(b.denominations) as Money_Spent from 
donordata as d join bonddata as b on d.unique_key=b.unique_key group by Year order by Money_Spent desc;

-- 5. In which month was the most amount spent on bonds? --

select extract(month from d.purchasedate) as Month, sum(b.denominations) as Money 
from donordata as d join bonddata as b on d.unique_key=b.unique_key 
group by Month order by Money desc limit 1;

-- 6. Find out which company bought the highest number of bonds. --

select d.purchaser, count(b.unique_key) as Bonds_purchased from donordata as d join 
bonddata as b on d.unique_key=b.unique_key group by 1 order by 2 desc limit 1;

-- 7. Find out which company spent the most on electoral bonds --

select d.purchaser as Company, sum(b.denominations) as Money_spent from donordata as d join 
bonddata as b on d.unique_key=b.unique_key group by 1 order by 2 desc limit 1; 

-- 8. List companies which paid the least to political parties --

select d.purchaser as Company, sum(b.denominations) as Money_spent from donordata as d join 
bonddata as b on d.unique_key=b.unique_key group by 1 having sum(denominations) = (
select min(money_spent) from (
select sum(denominations) as money_spent from donordata as d 
join bonddata as b on d.unique_key=b.unique_key group by purchaser) as subquery); 

-- 9. Which political party received the highest cash? --

select r.partyname, sum(b.denominations) as money_received from receiverdata as r join 
bonddata as b on r.unique_key=b.unique_key group by 1 order by 2 desc limit 1;

-- 10. Which political party received the highest number of electoral bonds? --

select r.partyname, count(b.unique_key) as electoral_bonds from receiverdata as r join 
bonddata as b on r.unique_key=b.unique_key group by 1 order by 2 desc limit 1;

-- 11. Which political party received the least cash? --

select r.partyname, sum(b.denominations) as Cash from receiverdata as r join 
bonddata as b on r.unique_key=b.unique_key group by 1 order by 2 asc limit 1;

-- 12. Which political party received the least number of electoral bonds? --

with spendingcounts as ( 
select partyname, count(denominations) as total_bonds from receiverdata as r join 
bonddata as b on r.unique_key=b.unique_key group by 1 order by 2 asc) 
select partyname, total_bonds as Electoral_bond from spendingcounts where 
total_bonds=(select min(total_bonds) from spendingcounts);

-- 13. Find the 2nd highest donor in terms of the amount paid --

with main as (
select purchaser, sum(denominations) as total from donordata as d join 
bonddata as b on d.unique_key=b.unique_key group by 1 order by 2), 
sub_cte as (select *, dense_rank() over(order by total desc) as ranks from main) 
select purchaser, total from sub_cte where ranks = 2;

-- 14. Find the party which received the second-highest donations. --

with first_cte as (
select partyname, sum(denominations) as Donations from receiverdata as r join 
bonddata as b on r.unique_key=b.unique_key group by 1 order by 2), 
sub_cte as (select *, dense_rank() over(order by Donations desc) as ranks from first_cte)
select partyname, Donations from sub_cte where ranks = 2;

-- 15. Find the party which received the second-highest number of bonds --

select partyname, count(denominations) as Bond_received from receiverdata as r join 
bonddata as b on r.unique_key=b.unique_key group by 1 order by 2 desc limit 1 offset 1;

-- 16. In which city were the most number of bonds purchased? --

select b.city, count(c.denominations) as total_bonds_purchased from bankdata as b 
join donordata as d on b.branchcodeno=d.paybranchcode 
join bonddata as c on c.unique_key=d.unique_key group by 1 order by 2 desc limit 1;

-- 17. In which city was the highest amount spent on electoral bonds? --

select b.city, sum(c.denominations) as Amount from bankdata as b 
join donordata as d on b.branchcodeno=d.paybranchcode 
join bonddata as c on c.unique_key=d.unique_key group by 1 order by 2 desc limit 1;

-- 18. In which city were the least number of bonds purchased? --

select b.city, count(c.denominations) as total_bonds_purchased from bankdata as b 
join donordata as d on b.branchcodeno=d.paybranchcode 
join bonddata as c on c.unique_key=d.unique_key group by 1 order by 2 asc limit 1;

-- 19. In which city were the most number of bonds encashed? --

select b.city, count(c.unique_key) as Bonds_encashed from bankdata as b 
join receiverdata as r on b.branchcodeno=r.paybranchcode 
join bonddata as c on c.unique_key=r.unique_key group by 1 order by 2 desc limit 1;

-- 20. In which city were the least number of bonds encashed? --

select b.city, count(c.unique_key) as Bonds_encashed from bankdata as b 
join receiverdata as r on b.branchcodeno=r.paybranchcode 
join bonddata as c on c.unique_key=r.unique_key group by 1 order by 2 asc limit 1;

 -- 21. List the branches where no electoral bonds were bought; if none, mention it as null. --

select city from bankdata b left join donordata d on 
b.branchCodeNo=d.PayBranchCode where d.PayBranchCode is null ;

 -- 22. Break down how much money is spent on electoral bonds for each year. --

same as question no 4:

 -- 23. Break down how much money is spent on electoral bonds for each year and provide the year and the amount. Provide values for the highest and least year and amount. --

with yearwisebonds as(
select Extract(year from purchasedate),sum(denominations) total_bond_value from donordata as d 
join bonddata as b on d.unique_key=b.unique_key group by 1) 
select 'Highest year ' as "Note",* from yearwisebonds 
where total_bond_value = (select max(total_bond_value) from yearwisebonds)
union select 'lowest year ' as "Note" ,* from yearwisebonds 
where total_bond_value = (select min(total_bond_value) from yearwisebonds);

-- 24. Find out how many donors bought the bonds but not donated to any political party? --

select count(*) from donordata as d left join receiverdata as r 
on d.unique_key=r.unique_key where r.partyname is null;

-- 25. Find out the money that could have went to PM office --

select sum(denominations) as "PM_Fund" from donordata as d 
left join receiverdata as r on d.unique_key=r.unique_key 
join bonddata as b on b.unique_key=d.unique_key where r.partyname is null;

-- 26. Find out how many bonds don't have donars associated with them. --

select count(*) from donordata d right join 
receiverdata r on r.unique_key = d.unique_key where purchaser is null;

-- 27. Find the employee_ID (payteller) who issued the highest number of bonds --

create view employee_bond_info as (
select d.payteller, count(b.unique_key) as "Employee_Count", sum(b.denominations) as "Employee_Amount" 
from donordata as d join bonddata as b on d.unique_key=b.unique_key group by 1 order by 2,3);

select payteller,"Employee_Count" from employee_bond_info where "Employee_Count" = 
(select max("Employee_Count") from employee_bond_info);

-- 28. Find the employee_ID (payteller) who issued the bonds for the highest amount --

select payteller, "Employee_Amount" from employee_bond_info where "Employee_Amount" = 
(select max("Employee_Amount") from employee_bond_info);

-- 29. Find the employee_ID (payteller) who issued the least number of bonds --

select payteller, "Employee_Count" from employee_bond_info where "Employee_Count" = 
(select min("Employee_Count") from employee_bond_info);

-- 30. Find the employee ID who issued the bonds for the least amount --

select payteller, "Employee_Amount" from employee_bond_info where "Employee_Amount" = 
(select min("Employee_Amount") from employee_bond_info);

-- 31. Find the employee_ID (payteller) who assisted in redeeming or encashing bonds in the highest number --

create view receiver_bond_info as (
select r.payteller, count(r.unique_key) as "Bond_Count", sum(b.denominations) as "Bond_Amount" 
from receiverdata as r join bonddata as b on r.unique_key=b.unique_key group by 1
);

select payteller, "Bond_Count" from receiver_bond_info where "Bond_Count" = 
(select max("Bond_Count") from receiver_bond_info);

-- 32. Find the employee_ID (payteller) who assisted in redeeming or encashing bonds for the highest amount --

select payteller, "Bond_Amount" from receiver_bond_info where "Bond_Amount" = 
(select max("Bond_Amount") from receiver_bond_info);

-- 33. Find the employee_ID (payteller) who assisted in redeeming or encashing bonds in the least number --

select payteller, "Bond_Count" from receiver_bond_info where "Bond_Count" = 
(select min("Bond_Count") from receiver_bond_info);

-- 34. Find the employee_ID (payteller) who assisted in redeeming or encashing bonds for the least amount --

select payteller, "Bond_Amount" from receiver_bond_info where "Bond_Amount" = 
(select min("Bond_Amount") from receiver_bond_info);


