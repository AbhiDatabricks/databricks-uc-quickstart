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
    WHEN data_sensitivity = 'LOW' THEN input_value
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
    WHEN access_level = 'DOCTOR' THEN medical_notes
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
- System table locks
- No optimization by query planner
- Breaks parallelization

**Performance Impact:** 🔥 **500x slower** (System table lookup per row)

---

## 🔴 ROW FILTER ANTI-PATTERNS

### ❌ Anti-Pattern #5: Complex JOIN Filters

**What NOT to Do:**
```sql
-- NEVER DO THIS - Complex JOIN in row filter
CREATE OR REPLACE FUNCTION filter_based_on_provider_network(provider_id STRING)
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  EXISTS (
    SELECT 1 
    FROM healthcare.providers p
    JOIN healthcare.provider_networks pn ON p.providerid = pn.providerid
    JOIN healthcare.user_network_access una ON pn.networkid = una.networkid
    WHERE una.user_region = 'SOME_REGION'
      AND p.providerid = provider_id  -- This breaks optimization!
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
CREATE OR REPLACE FUNCTION filter_by_user_clearance_level(patient_id STRING)
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  (
    SELECT clearance_level 
    FROM user_management.user_attributes 
    WHERE username = 'SOME_USER'
  ) >= (
    SELECT required_clearance 
    FROM healthcare.patient_security_levels 
    WHERE patientid = patient_id
  );
```

**Why This Destroys Performance:**
- Database lookup for every row
- Prevents vectorization
- Blocks column pruning
- Forces sequential processing

**Performance Impact:** 🔥 **1,000x slower** (2 lookups per row)

---

### ❌ Anti-Pattern #7: Time-Based Filters with Function Calls

**What NOT to Do:**
```sql
-- NEVER DO THIS - Complex time calculation per row
CREATE OR REPLACE FUNCTION filter_business_hours_complex()
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    WHEN EXTRACT(DOW FROM current_timestamp()) IN (1,7) THEN FALSE  -- Weekend
    WHEN EXTRACT(HOUR FROM CONVERT_TIMEZONE('America/New_York', current_timestamp())) NOT BETWEEN 8 AND 17 THEN FALSE
    WHEN EXISTS (
      SELECT 1 FROM company.holidays 
      WHERE holiday_date = CAST(current_timestamp() AS DATE)
    ) THEN FALSE
    ELSE TRUE
  END;
```

**Why This Kills Performance:**
- Timezone conversion per row
- Holiday lookup per row
- Multiple function calls
- Prevents predicate pushdown

**Performance Impact:** 🔥 **100x slower** (Multiple calculations per row)

---

### ❌ Anti-Pattern #8: Dynamic SQL Generation

**What NOT to Do:**
```sql
-- NEVER DO THIS - Dynamic SQL in filter function
CREATE OR REPLACE FUNCTION filter_dynamic_permissions()
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    WHEN user_role = 'ADMIN' THEN TRUE
    ELSE (
      -- This conceptually represents dynamic SQL - DON'T DO THIS
      SELECT COUNT(*) > 0
      FROM healthcare.dynamic_permissions
      WHERE CONTAINS(permission_sql, 'ADMIN')
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

### ⚠️ Anti-Pattern #9: Non-Deterministic Functions (Use With Extreme Caution)

**What to Be Careful With:**
```sql
-- BE VERY CAREFUL - Non-deterministic mask function
CREATE OR REPLACE FUNCTION mask_with_random()
RETURNS STRING
NOT DETERMINISTIC  -- Customer may explicitly want this!
RETURN 
  CASE 
    WHEN access_level IN ('ADMIN', 'MANAGER') THEN input_value
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
    WHEN access_level IN ('ADMIN', 'MANAGER') THEN input_value
    ELSE CONCAT('MASKED_', SHA2(CONCAT(input_value, DATE_FORMAT(current_date(), 'yyyy-MM-dd')), 256))
  END;
```

**Performance Impact:** 🔥 **No caching possible** + **JOIN failures** (But customer may explicitly accept this trade-off)

---

## ✅ PURE DATA-DRIVEN PATTERNS

### 🎯 Column-Based Logic Only

ABAC functions should focus purely on **data attributes and column values**. Unity Catalog policies handle user/group assignment separately, so functions only need to evaluate data properties.

**✅ EXCELLENT Pattern - Geographic Data Filtering:**

```sql
-- ✅ BEST PRACTICE - Pure column-based logic
CREATE OR REPLACE FUNCTION filter_by_country_access(ca_country STRING, data_classification STRING)
RETURNS BOOLEAN
RETURN 
  CASE
    WHEN data_classification = 'PUBLIC' THEN TRUE
    WHEN ca_country IN ('Australia', 'New Zealand') AND data_classification = 'REGIONAL' THEN TRUE
    WHEN ca_country IN ('Canada', 'United States') AND data_classification = 'NORTH_AMERICA' THEN TRUE
    WHEN ca_country = 'Global' AND data_classification = 'INTERNATIONAL' THEN TRUE
    ELSE FALSE
  END;
```

**✅ EXCELLENT Pattern - Data Classification Masking:**

```sql
-- ✅ BEST PRACTICE - Data sensitivity drives masking decisions
CREATE OR REPLACE FUNCTION mask_based_on_sensitivity(data_value STRING, sensitivity_level STRING, department STRING)
RETURNS STRING
RETURN 
  CASE
    WHEN sensitivity_level = 'PUBLIC' THEN data_value
    WHEN sensitivity_level = 'INTERNAL' AND department IN ('HR', 'ADMIN') THEN data_value
    WHEN sensitivity_level = 'INTERNAL' THEN 'INTERNAL_DATA'
    WHEN sensitivity_level = 'CONFIDENTIAL' AND department = 'EXECUTIVE' THEN data_value
    WHEN sensitivity_level = 'CONFIDENTIAL' THEN 'CONFIDENTIAL'
    WHEN sensitivity_level = 'RESTRICTED' THEN 'RESTRICTED'
    ELSE 'CLASSIFIED'
  END;
```

**Why This Works:**
- ✅ **Pure column logic** - business rules based only on data attributes
- ✅ **No external dependencies** - function evaluates only input parameters
- ✅ **Policy-level access control** - Unity Catalog handles who can use which functions
- ✅ **Maximum performance** - no lookups, no external calls
- ✅ **Clear business logic** - easy to understand data classification rules

---

## ✅ PERFORMANCE BEST PRACTICES

### 🚀 High-Performance Mask Function Pattern

```sql
-- ✅ EXCELLENT - Pure column-driven logic
CREATE OR REPLACE FUNCTION mask_patient_data_by_classification(
  patient_data STRING, 
  classification STRING,
  department STRING,
  access_level STRING
)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    -- Business logic based purely on data attributes
    WHEN classification = 'PUBLIC' THEN patient_data
    WHEN classification = 'GENERAL' AND department IN ('ADMIN', 'BILLING') THEN patient_data
    WHEN classification = 'MEDICAL' AND access_level = 'MEDICAL_STAFF' THEN patient_data
    WHEN classification = 'MEDICAL' THEN CONCAT('MED_', SHA2(patient_data, 256))
    WHEN classification = 'SENSITIVE' AND access_level = 'SENIOR_STAFF' THEN patient_data
    WHEN classification = 'SENSITIVE' THEN 'SENSITIVE_DATA'
    ELSE 'CLASSIFIED'
  END;
```

**Alternative Pattern - Geographic Access Control:**
```sql
-- ✅ EXCELLENT - Location-based data access logic
CREATE OR REPLACE FUNCTION mask_by_region_and_clearance(
  data_value STRING,
  patient_region STRING,
  data_sensitivity STRING,
  user_region_clearance STRING
)
RETURNS STRING
DETERMINISTIC
RETURN 
  CASE 
    WHEN data_sensitivity = 'LOW' THEN data_value
    WHEN data_sensitivity = 'MEDIUM' AND patient_region = user_region_clearance THEN data_value
    WHEN data_sensitivity = 'MEDIUM' THEN CONCAT('REG_', LEFT(SHA2(data_value, 256), 8))
    WHEN data_sensitivity = 'HIGH' AND patient_region = user_region_clearance AND user_region_clearance IN ('US_WEST', 'US_EAST') THEN data_value
    WHEN data_sensitivity = 'HIGH' THEN 'HIGH_SECURITY_DATA'
    ELSE 'RESTRICTED'
  END;
```

**Ultra-Fast Pattern - Pure Data Attributes:**
```sql
-- ✅ FASTEST - Pure data-driven logic, maximum performance
CREATE OR REPLACE FUNCTION mask_by_data_attributes(
  data_value STRING,
  is_public BOOLEAN,
  risk_level INT,
  expiry_date DATE
)
RETURNS STRING  
DETERMINISTIC
RETURN
  CASE
    WHEN is_public = TRUE THEN data_value
    WHEN expiry_date < current_date() THEN 'EXPIRED_DATA'
    WHEN risk_level <= 2 THEN CONCAT('LOW_', LEFT(data_value, 3), '***')
    WHEN risk_level <= 4 THEN CONCAT('MED_', SHA2(data_value, 256))
    ELSE 'HIGH_RISK_DATA'
  END;
```

**Why This Works:**
- ✅ **Pure data attribute logic** - business rules based only on column values
- ✅ **No external dependencies** - function evaluates only input parameters
- ✅ **Maximum performance** - no lookups, no function calls, no external checks
- ✅ **Policy-level access control** - Unity Catalog handles user/group targeting
- ✅ **Clear business rules** - easy to understand and maintain
- ✅ **Optimizable by Spark** - column-based predicates allow full pushdown optimization

---

### 🚀 High-Performance Row Filter Pattern

```sql
-- ✅ EXCELLENT - Pure column-driven filtering logic
CREATE OR REPLACE FUNCTION filter_by_region_and_clearance(
  patient_region STRING,
  clearance_required STRING,
  user_clearance_level STRING,
  user_region_access STRING
)
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    -- No restrictions for public data
    WHEN clearance_required = 'NONE' THEN TRUE
    
    -- Regional access based on user clearance and region match
    WHEN clearance_required = 'STANDARD' THEN
      CASE
        WHEN user_clearance_level IN ('STANDARD', 'HIGH') AND patient_region = user_region_access THEN TRUE
        WHEN user_clearance_level = 'GLOBAL' THEN TRUE
        ELSE FALSE
      END
      
    -- High-clearance requires elevated access level
    WHEN clearance_required = 'HIGH' THEN
      CASE
        WHEN user_clearance_level = 'HIGH' AND patient_region = user_region_access THEN TRUE
        WHEN user_clearance_level = 'GLOBAL' THEN TRUE
        ELSE FALSE
      END
      
    ELSE FALSE
  END;
```

**Alternative Pattern - Time-Based Data Access:**
```sql
-- ✅ EXCELLENT - Temporal and data-driven access control
CREATE OR REPLACE FUNCTION filter_by_time_and_urgency(
  case_urgency STRING,
  created_time TIMESTAMP,
  user_schedule_type STRING,
  current_hour INT
)
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    -- Emergency cases - accessible based on user schedule type
    WHEN case_urgency = 'EMERGENCY' AND user_schedule_type = 'EMERGENCY' THEN TRUE
    
    -- Urgent cases - accessible during business hours or after-hours staff
    WHEN case_urgency = 'URGENT' THEN
      CASE
        WHEN current_hour BETWEEN 8 AND 18 AND user_schedule_type IN ('STANDARD', 'AFTER_HOURS') THEN TRUE
        WHEN user_schedule_type = 'AFTER_HOURS' THEN TRUE
        ELSE FALSE
      END
      
    -- Standard cases - business hours only
    WHEN case_urgency = 'STANDARD' THEN
      CASE
        WHEN current_hour BETWEEN 8 AND 17 AND user_schedule_type IN ('STANDARD', 'AFTER_HOURS') THEN TRUE
        ELSE FALSE
      END
      
    ELSE FALSE
  END;
```

**Ultra-Fast Pattern - Pure Data Logic:**
```sql
-- ✅ FASTEST - Pure column logic, maximum performance
CREATE OR REPLACE FUNCTION filter_by_data_properties(
  is_public_record BOOLEAN,
  data_classification STRING,
  expiry_date DATE,
  access_level_required STRING,
  user_access_level STRING
)
RETURNS BOOLEAN
DETERMINISTIC
RETURN 
  CASE 
    WHEN is_public_record = TRUE THEN TRUE
    WHEN expiry_date < current_date() THEN FALSE
    WHEN data_classification = 'GENERAL' AND user_access_level IN ('GENERAL', 'ELEVATED', 'ADMIN') THEN TRUE
    WHEN data_classification = 'RESTRICTED' AND user_access_level IN ('ELEVATED', 'ADMIN') THEN TRUE
    WHEN data_classification = 'CLASSIFIED' AND user_access_level = 'ADMIN' THEN TRUE
    ELSE FALSE
  END;
```

**Why This Works:**
- ✅ **Pure column comparisons** - business rules based only on data attributes
- ✅ **No external function calls** - all logic contained within CASE statements
- ✅ **Maximum performance** - no lookups, no user/group resolution
- ✅ **Policy-level targeting** - Unity Catalog handles user/group assignment
- ✅ **Predicate pushdown friendly** - Spark can optimize column comparisons
- ✅ **Vectorizable operations** - batch processing of data with similar attributes

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

### **The 6 Commandments**

1. **Keep It Simple**: Simple logic = fast execution
2. **Stay Deterministic**: Same input = same output, always
3. **Avoid External Calls**: No network, no external systems
4. **Use Built-ins Only**: Leverage optimized Spark functions
5. **Pure Column Logic**: Functions should only evaluate input parameters and data attributes
6. **Test at Scale**: 1 million rows minimum for realistic testing

### **The Performance Checklist**

Before deploying any ABAC function, ask:

- [ ] Does this function use only built-in SQL functions?
- [ ] Is the logic deterministic and predictable?
- [ ] Can this be evaluated without external data lookups?
- [ ] Will this allow Spark to optimize the query plan?
- [ ] Does the function only use input parameters and column values?
- [ ] Are there no user/group membership function calls within the logic?
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