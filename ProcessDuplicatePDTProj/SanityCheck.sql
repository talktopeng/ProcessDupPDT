select name from nata.Product group by name having count(*) > 1				-- 47
select name from nata.Determination group by name having count(*) > 1		-- 402
select name from nata.Technique group by name having count(*) > 1			-- 0

select ProductId, ActivityServiceId from nata.ServiceProduct
group by ProductId, ActivityServiceId having count(*) > 1

select DeterminationId, ActivityServiceId from nata.ServiceDetermination
group by DeterminationId, ActivityServiceId having count(*) > 1

select DeterminationId, ActivityServiceId, count(*) from nata.ServiceDetermination sd
group by DeterminationId, ActivityServiceId having count(*) > 1

select DeterminationId, TechniqueId, ServiceDeterminationId,  count(*) from nata.DeterminationTechnique dt
group by DeterminationId, TechniqueId, ServiceDeterminationId having count(*) > 1