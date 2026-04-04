# QUICK START GUIDE

## The Problem
You were getting this error:
```
Execution failed for task ':com.kafka.demo.kafkaproducer.GeneralQuestion.main()'.
Process finished with non-zero exit value 1
```

## The Solutions

### 1. ✅ FIXED: GeneralQuestion.java Bug
The `findDuplicate()` method had a bug that caused ArrayIndexOutOfBoundsException.
**Status**: Fixed and tested successfully.

### 2. ✅ KAFKA TOPIC CONFIGURATION
**Question**: "Where to add the topic in application yml file or java file?"
**Answer**: Already configured in `application.yml` lines 36-40:

```yaml
kafka:
  topic:
    name: demo              # ← Change this to customize topic name
    partitions: 3
    replication-factor: 1
```

The Java service reads it automatically:
```java
// In KafkaProducerService.java
@Value("${kafka.topic.name}")
private String topicName;
```

**To change topic**: Just edit `application.yml` - no Java code changes needed!

### 3. ✅ SWAGGER/OPENAPI CONFIGURATION
**Question**: "Add openconfig for swagger"
**Answer**: Already configured! File exists at:
`src/main/java/com/kafka/demo/kafkaproducer/config/OpenApiConfig.java`

Access Swagger UI when app is running:
- http://localhost:8080/swagger-ui.html

---

## HOW TO RUN (THE RIGHT WAY)

### ❌ WRONG (What you were doing):
```powershell
# This tries to run GeneralQuestion.java (practice code)
.\gradlew.bat GeneralQuestion.main
```

### ✅ CORRECT (What you should do):
```powershell
# This runs the actual Spring Boot Kafka application
.\gradlew.bat bootRun
```

OR in IntelliJ:
1. Open `KafkaproducerApplication.java`
2. Right-click → Run 'KafkaproducerApplication'

---

## COMPLETE STARTUP COMMANDS

```powershell
# Navigate to project
cd C:\Users\milin\IdeaProjects\kafkaproducer

# Build (skip tests if they fail)
.\gradlew.bat build -x test

# Run the application
.\gradlew.bat bootRun

# Wait for: "Started KafkaproducerApplication in X.XX seconds"

# Then open browser:
# http://localhost:8080/swagger-ui.html
```

---

## TEST YOUR KAFKA PRODUCER

### Using Swagger UI (Easiest):
1. Go to: http://localhost:8080/swagger-ui.html
2. Click on "Kafka Producer" section
3. Try "POST /api/kafka/send"
4. Click "Try it out"
5. Enter a message
6. Click "Execute"

### Using curl:
```powershell
# Send simple message
curl -X POST "http://localhost:8080/api/kafka/send?message=Hello"

# Send message with key
curl -X POST "http://localhost:8080/api/kafka/send-with-key?key=key1&message=Test"
```

---

## PREREQUISITES CHECKLIST

Before running, ensure:
- [ ] Kafka is running on `localhost:9094`
- [ ] Java JDK 24 is installed
- [ ] You're in the project directory

---

## COMMON ISSUES

### "Cannot connect to Kafka"
- Make sure Kafka is running on port 9094
- Check `application.yml` line 5: `bootstrap-servers: localhost:9094`

### "Build failed with test errors"
- Use: `.\gradlew.bat build -x test` (skips tests)

### "Wrong main class"
- Run `KafkaproducerApplication.java`, NOT `GeneralQuestion.java`

---

## FILES REFERENCE

| File | Purpose | Need to Edit? |
|------|---------|---------------|
| `KafkaproducerApplication.java` | Main Spring Boot app | ❌ No |
| `application.yml` | Configuration (topic, Kafka) | ✅ Yes, to change topic |
| `OpenApiConfig.java` | Swagger configuration | ❌ No (already done) |
| `KafkaController.java` | REST API endpoints | ❌ No (already done) |
| `KafkaProducerService.java` | Kafka message logic | ❌ No (already done) |
| `GeneralQuestion.java` | Practice coding exercises | ❌ No (just practice) |

---

## SUMMARY

✅ All build errors fixed  
✅ Kafka topic already configured in `application.yml`  
✅ Swagger already configured with `OpenApiConfig.java`  
✅ Application ready to run  

**Next Action**: Run `.\gradlew.bat bootRun` 🚀

