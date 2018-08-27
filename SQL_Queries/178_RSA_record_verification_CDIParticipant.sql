
select distinct x.person_id, p.first_name as donor_first_name, p.last_name as donor_last_name, p.gender, p.dob,
       m.description as donation_intention, dt.description as donation_type,
       x.firstdonationdate, d.unit_number as fisrtunitnumber, def.description as RSADeferal,
       rp.person_id as rsa_person_id, rp.first_name as rsa_donor_first_name, rp.last_name as rsa_donor_last_name, 
       rp.gender as rsa_gender, rp.dob as rsa_dob
from (
select distinct r1.person_id, min(r1.registration_date) firstdonationdate
from CDI_SCHEMA_OWNER.REGISTRATION r1
group by r1.person_id) x
inner join CDI_SCHEMA_OWNER.REGISTRATION r on r.person_id = x.person_id and r.registration_date = x.firstdonationdate
left join CDI_SCHEMA_OWNER.DRAW dr on dr.registration_id = r.registration_id
left join CDI_SCHEMA_OWNER.DONATION d on d.registration_id = r.registration_id
left join CDI_SCHEMA_OWNER.PERSON p on r.person_id = p.person_id
left join CDI_SCHEMA_OWNER.MOTIVATION m on m.motivation_id = r.motivation_id
left join CDI_SCHEMA_OWNER.DONATION_TYPE dt on dt.donation_type_id = r.donation_type_id
left join COLLECTIONS_SCHEMA_OWNER.Person rp on rp.person_id = x.person_id
left join COLLECTIONS_SCHEMA_OWNER.Donor_Deferral dd on dd.person_id = rp.person_id
left join COLLECTIONS_SCHEMA_OWNER.Deferral def on def.deferral_code = dd.deferral_code
