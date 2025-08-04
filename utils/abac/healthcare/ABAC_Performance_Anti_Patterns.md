# ⚠️ ABAC Performance Anti-Patterns: What NOT to Do

## 🎯 Critical Performance Guidelines for Unity Catalog ABAC Functions

### 🚨 The Performance Reality Check

**ABAC policies run on EVERY query execution.** Poor function design can turn millisecond queries into multi-second disasters, making your data governance solution the bottleneck instead of the enabler.

---

## 🔴 MASK FUNCTION ANTI-PATTERNS

### ❌ Anti-Pattern #1: External API Calls in Mask Functions

**What NOT to Do:**
```sql
-- NEVER DO THIS - External API call in mask function
CREATE OR REPLACE FUNCTION mask_with_external_service(input_value STRING)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN is_member('sensitive_data_group') THEN input_value
    ELSE (SELECT response FROM external_api_call('https://masking-service.com/api/mask', input_value))
  END;
```

**Why This Kills Performance:**
- Network latency on every row
- External service timeouts block queries
- No caching of API responses
- Single point of failure

**Performance Impact:** 🔥 **10,000x slower** (1ms → 10+ seconds per row)

---

### ❌ Anti-Pattern #2: Complex Subqueries in Mask Functions

**What NOT to Do:**
```sql
-- NEVER DO THIS - Complex subquery in mask function
CREATE OR REPLACE FUNCTION mask_based_on_patient_history(patient_id STRING)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN (
      SELECT COUNT(*) 
      FROM healthcare.visits v 
      JOIN healthcare.labresults l ON v.visitid = l.visitid 
      WHERE v.patientid = patient_id 
        AND l.abnormalflag = 'High'
        AND v.visitdate > current_date() - INTERVAL 30 DAYS
    ) > 5 THEN 'HIGH_RISK_PATIENT'
    ELSE CONCAT('REF_', SHA2(patient_id, 256))
  END;
```

**Why This Destroys Performance:**
- Executes complex JOIN for every row
- No query optimization possible
- Cartesian product explosion risk
- Blocks parallel processing

**Performance Impact:** 🔥 **1,000x slower** (Complex JOIN per masked value)

---

### ❌ Anti-Pattern #3: String Operations on Large Text

**What NOT to Do:**
```sql
-- NEVER DO THIS - Expensive string operations
CREATE OR REPLACE FUNCTION mask_large_text(medical_notes STRING)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN is_member('doctor_group') THEN medical_notes
    ELSE REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(medical_notes, '\\d{3}-\\d{2}-\\d{4}', 'XXX-XX-XXXX'),  -- SSN
        '\\d{3}-\\d{3}-\\d{4}', 'XXX-XXX-XXXX'  -- Phone
      ),
      '[A-Za-z]+\\s+[A-Za-z]+', 'REDACTED NAME'  -- Names
    )
  END;
```

**Why This Kills Performance:**
- Multiple regex operations per row
- CPU-intensive on large text fields
- No early termination possible
- Memory allocation for each operation

**Performance Impact:** 🔥 **100x slower** on large text fields

---

### ❌ Anti-Pattern #4: Database Metadata Lookups

**What NOT to Do:**
```sql
-- NEVER DO THIS - Metadata lookup in mask function
CREATE OR REPLACE FUNCTION mask_based_on_column_sensitivity(value STRING, table_name STRING, column_name STRING)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN (
      SELECT sensitivity_level 
      FROM information_schema.column_tags 
      WHERE table_name = table_name 
        AND column_name = column_name
    ) = 'HIGH' THEN 'CLASSIFIED'
    ELSE value
  END;
```

**Why This Destroys Performance:**
- Metadata queries for every row
- Breaks parallelization

**Performance Impact:** 🔥 **500x slower** (System table lookup per row)

---

## 🔴 ROW FILTER ANTI-PATTERNS

### ❌ Anti-Pattern #5: Complex JOIN Filters

**What NOT to Do:**
```sql
-- NEVER DO THIS - Complex JOIN in row filter
CREATE OR REPLACE FUNCTION filter_based_on_provider_network()
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  EXISTS (
    SELECT 1 
    FROM healthcare.providers p
    JOIN healthcare.provider_networks pn ON p.providerid = pn.providerid
    JOIN healthcare.user_network_access una ON pn.networkid = una.networkid
    WHERE una.username = current_user()
      AND p.providerid = healthcare.visits.providerid  -- This breaks optimization!
  );
```

**Why This Kills Performance:**
- Forces nested loop joins
- Prevents pushdown optimization
- Blocks parallel execution
- Creates dependency on other tables

**Performance Impact:** 🔥 **10,000x slower** (Complex JOIN per row evaluation)

---

### ❌ Anti-Pattern #6: User Attribute Lookups Per Row

**What NOT to Do:**
```sql
-- NEVER DO THIS - User lookup for every row
CREATE OR REPLACE FUNCTION filter_by_user_clearance_level()
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  (
    SELECT clearance_level 
    FROM user_management.user_attributes 
    WHERE username = current_user()
  ) >= (
    SELECT required_clearance 
    FROM healthcare.patient_security_levels 
    WHERE patientid = healthcare.patients.patientid
  );
```

**Why This Destroys Performance:**
- Database lookup for every row
- Prevents vectorization
- Blocks column pruning
- Forces sequential processing

**Performance Impact:** 🔥 **1,000x slower** (2 lookups per row)



---

### ❌ Anti-Pattern #7: Dynamic SQL Generation

**What NOT to Do:**
```sql
-- NEVER DO THIS - Dynamic SQL in filter function
CREATE OR REPLACE FUNCTION filter_dynamic_permissions()
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    WHEN current_user() LIKE '%_admin' THEN TRUE
    ELSE (
      -- This conceptually represents dynamic SQL - DON'T DO THIS
      SELECT COUNT(*) > 0
      FROM healthcare.dynamic_permissions
      WHERE CONTAINS(permission_sql, current_user())
        AND CONTAINS(permission_sql, 'patients')
    )
  END;
```

**Why This Breaks Everything:**
- Unpredictable execution plans
- SQL injection risks
- No query optimization
- Impossible to cache

**Performance Impact:** 🔥 **Query planning failure**

---

### ⚠️ Anti-Pattern #8: Non-Deterministic Functions (Use With Extreme Caution)

**What to Be Careful With:**
```sql
-- BE VERY CAREFUL - Non-deterministic mask function
CREATE OR REPLACE FUNCTION mask_with_random()
RETURNS STRING
NOT DETERMINISTIC  -- Customer may explicitly want this!
RETURN 
  CASE 
    WHEN is_member('full_access_group') THEN input_value
    ELSE CONCAT('MASKED_', CAST(RAND() * 1000000 AS INT))
  END;
```

**⚠️ Customer Use Cases for Non-Deterministic Functions:**
- **Dynamic Obfuscation**: Customer wants different masked values each time for enhanced security
- **Audit Trail Confusion**: Intentionally make it harder to correlate masked data across queries
- **Research Randomization**: Statistical studies requiring different sample sets per execution
- **Security Through Obscurity**: Change masked values to prevent pattern recognition

**Performance & Functional Trade-offs:**
- ❌ Results change between query executions
- ❌ Breaks JOIN consistency across queries
- ❌ Prevents result caching and optimization
- ❌ Makes debugging and troubleshooting difficult
- ❌ Can break analytics and reporting workflows

**⚠️ When Customers Explicitly Want This:**
If customer requires non-deterministic behavior, ensure they understand:
1. **Performance cost**: 10-50x slower due to no caching
2. **JOIN implications**: Cross-query joins will fail
3. **Analytics impact**: Reports may be inconsistent
4. **Debugging complexity**: Troubleshooting becomes much harder

**Recommended Alternative:**
```sql
-- BETTER APPROACH - Deterministic with time-based seed
CREATE OR REPLACE FUNCTION mask_with_time_seed(input_value STRING)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN is_member('full_access_group') THEN input_value
    ELSE CONCAT('MASKED_', SHA2(CONCAT(input_value, DATE_FORMAT(current_date(), 'yyyy-MM-dd')), 256))
  END;
```

**Performance Impact:** 🔥 **No caching possible** + **JOIN failures** (But customer may explicitly accept this trade-off)

---

## ✅ PERFORMANCE BEST PRACTICES

### 🚀 High-Performance Mask Function Pattern

```sql
-- ✅ EXCELLENT - Simple, deterministic, fast
CREATE OR REPLACE FUNCTION mask_patient_id_fast(patient_id STRING)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN is_member('healthcare_analyst') THEN CONCAT('REF_', SHA2(patient_id, 256))
    WHEN is_member('junior_staff') THEN 'MASKED_ID'
    WHEN is_member('senior_doctor') THEN patient_id
    ELSE 'UNAUTHORIZED'
  END;
```

**Why This Works:**
- ✅ Simple CASE statement
- ✅ Built-in functions only
- ✅ Deterministic results
- ✅ No external dependencies

---

### 🚀 High-Performance Row Filter Pattern

```sql
-- ✅ EXCELLENT - Simple boolean logic
CREATE OR REPLACE FUNCTION filter_by_region_fast()
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    WHEN is_member('admin_group') THEN TRUE
    WHEN is_member('texas_regional') AND (state = 'TX' OR state = 'texas') THEN TRUE
    WHEN is_member('california_regional') AND (state = 'CA' OR state = 'california') THEN TRUE
    ELSE FALSE
  END;
```

**Why This Works:**
- ✅ Simple boolean logic
- ✅ Column references only
- ✅ Allows predicate pushdown
- ✅ Vectorizable operations

---

## 📊 Performance Comparison

| Pattern Type | Query Time | Scalability | Optimization |
|-------------|------------|-------------|--------------|
| ❌ External API calls | 10+ seconds | Breaks | None |
| ❌ Complex subqueries | 1-5 seconds | Poor | Limited |
| ❌ Non-deterministic | Variable | Broken | None |
| ❌ String regex operations | 100-500ms | Poor | Limited |
| ❌ Metadata lookups | 500ms-2s | Poor | None |
| ✅ Simple CASE/boolean | 1-10ms | Excellent | Full |

---

## 🎯 Golden Rules for ABAC Performance

### **The 5 Commandments**

1. **Keep It Simple**: Simple logic = fast execution
2. **Stay Deterministic**: Same input = same output, always
3. **Avoid External Calls**: No network, no external systems
4. **Use Built-ins Only**: Leverage optimized Spark functions
5. **Test at Scale**: 1 million rows minimum for realistic testing

### **The Performance Checklist**

Before deploying any ABAC function, ask:

- [ ] Does this function use only built-in SQL functions?
- [ ] Is the logic deterministic and predictable?
- [ ] Can this be evaluated without external data lookups?
- [ ] Will this allow Spark to optimize the query plan?
- [ ] Have I tested this with realistic data volumes?

---

## 🔧 Performance Testing Framework

### **Load Test Template**

```sql
-- Performance test your ABAC functions
WITH test_data AS (
  SELECT 
    patient_id,
    your_mask_function(patient_id) as masked_id,
    current_timestamp() as start_time
  FROM (
    SELECT CONCAT('PAT', LPAD(seq, 6, '0')) as patient_id
    FROM range(1000000)  -- 1 million test rows
  )
)
SELECT 
  COUNT(*) as rows_processed,
  MAX(start_time) - MIN(start_time) as total_duration,
  COUNT(*) / EXTRACT(EPOCH FROM (MAX(start_time) - MIN(start_time))) as rows_per_second
FROM test_data;
```

### **Performance Targets**

- **Mask Functions**: >100,000 rows/second
- **Row Filters**: >500,000 rows/second  
- **Query Overhead**: <10% additional latency
- **Memory Usage**: <2x baseline query

---

## 🚨 Emergency Performance Recovery

### **When ABAC Functions Kill Performance**

1. **Immediate Action**: Carefully drop problematic policies in dev environment first, then production if necessary

2. **Diagnosis**: Check query execution plans
   ```sql
   EXPLAIN EXTENDED SELECT * FROM your_table LIMIT 10;
   ```

3. **Fix**: Rewrite using performance patterns above

4. **Validation**: Load test before re-enabling

---

**🎯 Remember: Great ABAC is invisible ABAC. Your users should never know it's there.**

---
