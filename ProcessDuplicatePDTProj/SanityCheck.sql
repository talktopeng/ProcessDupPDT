select name from nata.Product group by name having count(*) > 1				-- 47
select name from nata.Determination group by name having count(*) > 1		-- 402
select name from nata.Technique group by name having count(*) > 1			-- 0

