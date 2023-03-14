create database BensPizza 

create table orders(
row_id int not null primary key,
order_id varchar(10),
created_at DATETIME,
item_id int,
quantity int,
cust_id int,
delivery BIT,
add_id int,
foreign key (cust_id) references customers(cust_id),
foreign key (add_id) references address(add_id),
foreign key (item_id) references item(item_id)
);


create table customers(
    cust_id int primary KEY,
    cust_firstname varchar(50),
    cust_lastname varchar(50)
)

create table address(
   add_id int not null primary key,
   delivery_address1 varchar(200),
   delivery_address2 null varchar(200),
   delivery_city varchar(50),
   delivery_zipcode varchar(20)
)


create table item(
    item_id int primary key,
    sku varchar(20),
    item_name varchar(100),
    item_cat varchar(50),
    item_size varchar(20),
    item_price decimal(5,2)

)

create table recipe(
    row_id int primary key,
    recipe_id varchar(20),
    ing_id varchar(20),
    quantity int, 
    foreign key (ing_id) references ingredient(ing_id)

)


create table ingredient(
    ing_id varchar(20) primary key,
    ing_name varchar(200),
    ing_weight int,
    ing_meas varchar(20),
    ing_price decimal(5,2)
)

create table inventory(
    inv_id varchar(50) primary key,
    ing_id varchar(20),
    quantity INT
    foreign key (ing_id) references ingredient(ing_id)
)
--Staff tables

create table staff(
    staff_id varchar(20) primary key,
    first_name varchar(50),
    last_name varchar(50),
    position varchar(100),
    hourly_rate decimal(5,2)
);

create table shift(
    shift_id varchar(20) primary key,
    day_of_week varchar(10),
    start_time time,
    end_time time
)

create table rota(
    row_id int primary key,
    rota_id varchar(20),
    date datetime,
    shift_id varchar(20),
    staff_id varchar(20),
    foreign key (shift_id) references shift(shift_id),
    foreign key (staff_id) references staff(staff_id)
)

-- Inserting Sample data into all tables

insert into ingredient VALUES
('ING001','Tomato sauce',4500, 'grams',3.89),
('ING002','Dried Oregano',500, 'grams',5.99)

insert into orders VALUES
(1,'109','2022-08-10 13:22:58',1,2,1,1,1),
(2, '110','2022-08-10 13:53:07',3,1,2,1,2)

insert into customers VALUES
(1,'Yaswanthi','Polineni'),
(2,'Gopi','Ande')

insert into address VALUES
(1,'Golden Street Road','Rajeev Nagar','Ongole','523002'),
(2,'Indira Nagar','Gachibowli','Hyderabad','500032')

insert into item VALUES
(1,'PIZZ-DIAV-R','Pizza Diavola (hot) Reg','Pizza','Regular',16.00),
(3,'BREAD-STICK','Breadsticks','Side','Regular',5.00)


insert into recipe VALUES
(1,'PIZZ-DIAV-R','ING001',250),
(2,'PIZZ-DIAV-R','ING002',80),
(3,'BREAD-STICK','ING003',170),
(4,'BREAD-STICK','ING004',5)

insert into inventory VALUES
('INV01','ING001',500),
('INV02','ING002',200),
('INV03','ING003',50),
('INV04','ING004',100)

insert into ingredient VALUES
('ING003','Yeast',5,'grams',4),
('ING004','Oil',2,'Ounce',10)


insert into shift VALUES
('sh0001','Monday','10:30:00','14:00:00'),
('sh0002','Tuesday','10:30:00','14:00:00'),
('sh0003','Wednesday','10:30:00','14:00:00')

insert into staff values 
('st0001','Ivan','English','Chef','17.25'), 
('st0002','Mindy','Sloan','Delivery Rider','14.5'), 
('st0003','Desiree','Gardener','Delivery Rider','14.5')

insert into rota VALUES
(1,'ro0001','2022-08-10 13:22:58.000','sh0003','st0002'),
(2,'ro0002','2022-08-10 13:53:07.000','sh0003','st0003'),
(3,'ro0003','2022-08-10','sh0003','st0001')


--Total orders, sales, Items, Average order value for data
select o.order_id,i.item_price,o.quantity,i.item_cat,i.item_name,o.created_at,a.delivery_address1, a.delivery_address2,a.delivery_city,a.delivery_zipcode,o.delivery 
from orders o 
left join item i on o.item_id=i.item_id
left join address a on o.add_id=a.add_id

--Inventory Management- Total quantity of ingredient, total cost of ingredients, Calculate cost of Pizza and % stock remaining by ingredient
select 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
ing.ing_name,
r.quantity as recipe_quantity,
sum(o.quantity) as order_quantity,
ing.ing_weight,
ing.ing_price
from orders o 
left join item i on o.item_id=i.item_id
left join recipe r on i.sku=r.recipe_id
left join ingredient ing on ing.ing_id=r.ing_id
group by 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
r.quantity,
ing.ing_name,
ing.ing_weight,
ing.ing_price

-- Determine- Total quantity by ingredient, total cost of ingredients, calculated cost of pizza, percentage stock remaining by ingredient, list of ingredients
--to reorder based on remaining inventory.  Subqueries to calculate cost
select 
s1.item_name,
s1.ing_id,
s1.ing_name,
s1.ing_weight,
s1.ing_price,
s1.recipe_quantity,
s1.order_quantity*s1.recipe_quantity as ordered_weight,
s1.ing_price/s1.ing_weight as unit_cost,
(s1.order_quantity*s1.recipe_quantity)*(s1.ing_price/s1.ing_weight) as ingredient_cost
from (select 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
ing.ing_name,
r.quantity as recipe_quantity,
sum(o.quantity) as order_quantity,
ing.ing_weight,
ing.ing_price
from orders o 
left join item i on o.item_id=i.item_id
left join recipe r on i.sku=r.recipe_id
left join ingredient ing on ing.ing_id=r.ing_id
group by 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
r.quantity,
ing.ing_name,
ing.ing_weight,
ing.ing_price) s1

--Creating View
create view stock1 AS 
(
select 
s1.item_name,
s1.ing_id,
s1.ing_name,
s1.ing_weight,
s1.ing_price,
s1.recipe_quantity,
s1.order_quantity*s1.recipe_quantity as ordered_weight,
s1.ing_price/s1.ing_weight as unit_cost,
(s1.order_quantity*s1.recipe_quantity)*(s1.ing_price/s1.ing_weight) as ingredient_cost
from (select 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
ing.ing_name,
r.quantity as recipe_quantity,
sum(o.quantity) as order_quantity,
ing.ing_weight,
ing.ing_price
from orders o 
left join item i on o.item_id=i.item_id
left join recipe r on i.sku=r.recipe_id
left join ingredient ing on ing.ing_id=r.ing_id
group by 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
r.quantity,
ing.ing_name,
ing.ing_weight,
ing.ing_price) s1    
)

--Remaining weight which needs to be ordered for each ingredient to deliver the orders
select s2.ing_name,s2.ordered_weight,ing.ing_weight,inv.quantity, 
ing.ing_weight* inv.quantity as total_inv_weight,
(ing.ing_weight* inv.quantity) - ordered_weight as remaining_weight
from 
(select ing_id,ing_name,sum(ordered_weight) as ordered_weight 
from stock1
group by ing_id,ing_name) s2
left join inventory inv on inv.ing_id=s2.ing_id
left join ingredient ing on ing.ing_id=s2.ing_id

-- Calculate staff costs
select 
r.date,
s.first_name,
s.last_name,
s.hourly_rate,
sh.start_time,
sh.end_time,
-- ((hour(timediff(sh.end_time,sh.start_time))*60)+(minute(timediff(sh.end_time,sh.start_time)))))/60 as hours_in_shift,
-- ((hour(timediff(sh.end_time,sh.start_time))*60)+(minute(timediff(sh.end_time,sh.start_time)))))/60 *s.hourly_rate as staff_cost
datediff(hh,sh.start_time,sh.end_time) as hours_in_shift,
(datediff(hh,sh.start_time,sh.end_time)*s.hourly_rate)  as staff_cost
from rota r
left join staff s on r.staff_id=s.staff_id
left join shift sh on r.shift_id=sh.shift_id

select * from inventory;
select * from ingredient
select DATA_TYPE from BensPizza.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='shift'

