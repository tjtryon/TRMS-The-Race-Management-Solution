-- ═══════════════════════════════════════════════════════════════════════════════
-- 👁️ TRMS Database Views
-- ═══════════════════════════════════════════════════════════════════════════════

USE trms_db;

-- =============================================
-- RACE SUMMARY VIEW
-- =============================================
CREATE OR REPLACE VIEW race_summary AS
SELECT 
    r.race_id,
    r.race_name,
    r.race_date,
    r.race_venue,
    r.race_type,
    r.registration_open,
    COUNT(DISTINCT p.participant_id) as registered_count,
    COUNT(DISTINCT rt.participant_id) as finished_count,
    r.registration_limit,
    r.entry_fee,
    CASE 
        WHEN r.race_date > CURDATE() THEN 'upcoming'
        WHEN r.race_date = CURDATE() THEN 'today'
        ELSE 'completed'
    END as status
FROM races r
LEFT JOIN participants p ON r.race_id = p.race_id AND p.registration_status = 'confirmed'
LEFT JOIN race_times rt ON r.race_id = rt.race_id AND rt.timing_status = 'finished'
GROUP BY r.race_id;

-- =============================================
-- PARTICIPANT DETAILS VIEW
-- =============================================
CREATE OR REPLACE VIEW participant_details AS
SELECT 
    p.participant_id,
    p.race_id,
    r.race_name,
    CONCAT(p.first_name, ' ', p.last_name) as full_name,
    p.email,
    p.phone,
    p.distance,
    p.bib_number,
    p.registration_status,
    p.payment_status,
    p.amount_paid,
    rt.finish_time,
    rt.net_time,
    rt.overall_place,
    rt.timing_status
FROM participants p
JOIN races r ON p.race_id = r.race_id
LEFT JOIN race_times rt ON p.participant_id = rt.participant_id;

-- =============================================
-- RACE RESULTS VIEW
-- =============================================
CREATE OR REPLACE VIEW race_results AS
SELECT 
    rt.race_id,
    r.race_name,
    rt.participant_id,
    CONCAT(p.first_name, ' ', p.last_name) as participant_name,
    rt.bib_number,
    p.distance,
    rt.start_time,
    rt.finish_time,
    rt.net_time,
    rt.overall_place,
    rt.gender_place,
    rt.age_group_place,
    rt.timing_status
FROM race_times rt
JOIN races r ON rt.race_id = r.race_id
LEFT JOIN participants p ON rt.participant_id = p.participant_id
WHERE rt.timing_status IN ('finished', 'dnf', 'dsq')
ORDER BY rt.race_id, rt.overall_place;
