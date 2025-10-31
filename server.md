# TGM HydroAI Chat Backend Server Documentation

## Overview

This document outlines the complete backend infrastructure and jobs required to make the TGM HydroAI Chat application fully functional. The app uses a **dual-backend architecture**:
- **Strapi CMS** for company users (business accounts)
- **PocketBase** for individual users (personal accounts)
- **RAGFlow** for AI chat capabilities

This hybrid approach allows for different data models, authentication flows, and feature sets while maintaining a unified user experience.

## Architecture Components

### 1. Primary Backend Services

#### 1.1 Strapi CMS (Company Users Backend)

**Purpose**: Company user authentication, profile management, and business account features
**Technology**: Node.js-based headless CMS
**Location**: Should be deployed separately (e.g., `https://company-api.tgmai.com`)
**User Type**: Company accounts with company codes

**Content Types Required**:
- **Users** (Built-in Strapi user management)
- **User Profiles** (Extended user data with company info)
- **Companies** (Company account management)
- **Subscriptions** (Enterprise plan management)
- **Messages** (Chat message storage)
- **Conversations** (Chat session management)
- **Notifications** (System notifications)

#### 1.2 PocketBase (Individual Users Backend)

**Purpose**: Individual user authentication, profile management, and personal account features
**Technology**: Go-based backend-as-a-service
**Location**: Should be deployed separately (e.g., `https://individual-api.tgmai.com`)
**User Type**: Individual accounts with social login

**Collections Required**:
- **users** (Built-in PocketBase user management)
- **user_profiles** (Extended user data)
- **subscriptions** (Personal plan management)
- **messages** (Chat message storage)
- **conversations** (Chat session management)
- **notifications** (System notifications)

#### 1.3 API Gateway Service

**Purpose**: Route requests to appropriate backend based on user type
**Technology**: Node.js/Express with routing logic
**Location**: Main entry point (e.g., `https://api.tgmai.com`)

**Responsibilities**:
- User type detection and routing
- Authentication token validation
- Request/response transformation
- Backend synchronization
- Unified API interface

#### 1.4 RAGFlow AI Service

**Purpose**: AI chat completions, document processing, and knowledge base management
**Technology**: Python-based RAG (Retrieval-Augmented Generation) service
**Location**: Should be deployed separately (e.g., `https://ai.tgmai.com`)

### 2. Database Objects

#### 2.1 Strapi Database Schema (Company Users)

```sql
-- Users table (Strapi built-in)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    password VARCHAR(255),
    provider VARCHAR(255),
    confirmed BOOLEAN DEFAULT false,
    blocked BOOLEAN DEFAULT false,
    role_id INTEGER,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Company User Profiles
CREATE TABLE user_profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    name VARCHAR(255),
    avatar_url TEXT,
    user_type VARCHAR(20) DEFAULT 'company',
    company_code VARCHAR(6) NOT NULL,
    company_id INTEGER REFERENCES companies(id),
    current_plan VARCHAR(50) DEFAULT 'Enterprise',
    plan_expiry_date TIMESTAMP,
    message_count INTEGER DEFAULT 0,
    days_active INTEGER DEFAULT 0,
    rating DECIMAL(2,1) DEFAULT 4.8,
    join_date TIMESTAMP,
    conversations_count INTEGER DEFAULT 0,
    last_active TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Companies
CREATE TABLE companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    company_code VARCHAR(6) UNIQUE,
    domain VARCHAR(255),
    plan VARCHAR(50) DEFAULT 'Enterprise',
    max_users INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    admin_user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Subscriptions
CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    plan_name VARCHAR(50),
    price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',
    status ENUM('active', 'cancelled', 'expired'),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    payment_method JSONB,
    stripe_subscription_id VARCHAR(255),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Conversations
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255),
    ragflow_session_id VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    message_count INTEGER DEFAULT 0,
    last_message_at TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Messages
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES conversations(id),
    user_id INTEGER REFERENCES users(id),
    content TEXT,
    is_user BOOLEAN,
    message_type ENUM('text', 'image', 'audio'),
    image_url TEXT,
    audio_url TEXT,
    audio_duration INTEGER,
    status ENUM('sending', 'sent', 'delivered', 'failed'),
    ragflow_message_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Notifications
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255),
    message TEXT,
    type ENUM('info', 'warning', 'error', 'success'),
    is_read BOOLEAN DEFAULT false,
    action_url TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Usage Statistics (Company Users)
CREATE TABLE usage_statistics (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    date DATE,
    messages_sent INTEGER DEFAULT 0,
    ai_responses INTEGER DEFAULT 0,
    audio_messages INTEGER DEFAULT 0,
    image_messages INTEGER DEFAULT 0,
    session_duration INTEGER DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(user_id, date)
);
```

#### 2.2 PocketBase Schema (Individual Users)

PocketBase uses collections (similar to tables). Here's the schema definition:

```javascript
// users collection (PocketBase built-in)
{
  "id": "string (auto-generated)",
  "username": "string (unique)",
  "email": "string (unique)",
  "emailVisibility": "boolean",
  "verified": "boolean",
  "avatar": "file",
  "password": "string (hashed)",
  "created": "datetime",
  "updated": "datetime"
}

// user_profiles collection
{
  "id": "string (auto-generated)",
  "user": "relation (users)",
  "name": "string",
  "avatar_url": "url",
  "user_type": "select (individual)",
  "current_plan": "select (Free, Pro, Premium)",
  "plan_expiry_date": "datetime",
  "message_count": "number (default: 0)",
  "days_active": "number (default: 0)",
  "rating": "number (default: 4.8)",
  "join_date": "datetime",
  "conversations_count": "number (default: 0)",
  "last_active": "datetime",
  "metadata": "json",
  "created": "datetime",
  "updated": "datetime"
}

// subscriptions collection
{
  "id": "string (auto-generated)",
  "user": "relation (users)",
  "plan_name": "select (Free, Pro, Premium)",m designed to be helpful, informative, and conversational. Feel free to ask me any
  "price": "number",
  "currency": "string (default: USD)",
  "status": "select (active, cancelled, expired)",
  "start_date": "datetime",
  "end_date": "datetime",
  "payment_method": "json",
  "stripe_subscription_id": "string",
  "created": "datetime",
  "updated": "datetime"
}

// conversations collection
{
  "id": "string (auto-generated)",
  "user": "relation (users)",
  "title": "string",
  "ragflow_session_id": "string",
  "is_active": "boolean (default: true)",
  "message_count": "number (default: 0)",
  "last_message_at": "datetime",
  "metadata": "json",
  "created": "datetime",
  "updated": "datetime"
}

// messages collection
{
  "id": "string (auto-generated)",
  "conversation": "relation (conversations)",
  "user": "relation (users)",
  "content": "text",
  "is_user": "boolean",
  "message_type": "select (text, image, audio)",
  "image": "file",
  "audio": "file",
  "audio_duration": "number",
  "status": "select (sending, sent, delivered, failed)",
  "ragflow_message_id": "string",
  "metadata": "json",
  "created": "datetime",
  "updated": "datetime"
}

// notifications collection
{
  "id": "string (auto-generated)",
  "user": "relation (users)",
  "title": "string",
  "message": "text",
  "type": "select (info, warning, error, success)",
  "is_read": "boolean (default: false)",
  "action_url": "url",
  "created": "datetime",
  "updated": "datetime"
}

// usage_statistics collection
{
  "id": "string (auto-generated)",
  "user": "relation (users)",
  "date": "date",
  "messages_sent": "number (default: 0)",
  "ai_responses": "number (default: 0)",
  "audio_messages": "number (default: 0)",
  "image_messages": "number (default: 0)",
  "session_duration": "number (default: 0)",
  "created": "datetime",
  "updated": "datetime"
}
```

## 3. Backend Jobs and Scheduled Tasks

### 3.1 Critical Production Jobs

#### Job 1: API Gateway Service
**Purpose**: Route requests to appropriate backend (Strapi or PocketBase) based on user type
**Technology**: Node.js/Express with routing logic
**Schedule**: Real-time (API endpoints)
**Priority**: High

**Implementation Requirements**:
- User type detection from tokens or user data
- Request routing to appropriate backend
- Response transformation and normalization
- Token validation for both backends
- Error handling and fallback mechanisms
- Request/response logging and monitoring

**Routing Logic**:
```javascript
// Route based on user type
if (userType === 'company') {
  // Forward to Strapi backend
  proxyToStrapi(req, res);
} else {
  // Forward to PocketBase backend
  proxyToPocketBase(req, res);
}
```

**API Endpoints**:
```
GET /health
POST /route-auth/*
POST /route-api/*
GET /user-type/:identifier
```

#### Job 2: Dual Authentication Service
**Purpose**: Handle authentication for both Strapi (company) and PocketBase (individual) users
**Technology**: Node.js/Express with dual backend support
**Schedule**: Real-time (API endpoints)
**Priority**: High

**Implementation Requirements**:
- Dual JWT token management (Strapi + PocketBase tokens)
- User type detection during registration/login
- Company code validation for business accounts
- Social login integration for individual users
- Device fingerprinting for security
- Rate limiting for brute force protection
- Token refresh mechanism for both backends

**API Endpoints**:
```
POST /auth/register/individual
POST /auth/register/company
POST /auth/login
POST /auth/logout
POST /auth/refresh
GET /auth/me
POST /auth/forgot-password
POST /auth/reset-password
POST /auth/validate-company-code
```

#### Job 3: Dual Subscription Management Service
**Purpose**: Handle subscription lifecycle for both individual (PocketBase) and company (Strapi) users
**Technology**: Node.js with Stripe integration + dual backend support
**Schedule**: Real-time + Daily cron job
**Priority**: High

**Implementation Requirements**:
- Stripe webhook handling
- Dual plan management (Individual: Free/Pro/Premium, Company: Enterprise)
- Payment method management for both user types
- Usage limit enforcement per backend
- Automatic plan expiry handling
- Company-wide billing for business accounts
- Per-user billing for individual accounts

**Scheduled Tasks**:
```bash
# Daily at 00:00 UTC - Check subscription expiry (both backends)
0 0 * * * /usr/local/bin/node /app/jobs/check-subscription-expiry-strapi.js
0 0 * * * /usr/local/bin/node /app/jobs/check-subscription-expiry-pocketbase.js

# Hourly - Process pending payments (both backends)
0 * * * * /usr/local/bin/node /app/jobs/process-payments-strapi.js
0 * * * * /usr/local/bin/node /app/jobs/process-payments-pocketbase.js
```

**API Endpoints**:
```
GET /subscriptions/plans/:userType
POST /subscriptions/create-checkout-session/:userType
POST /subscriptions/upgrade/:userType
POST /subscriptions/cancel/:userType
GET /subscriptions/status/:userType
POST /webhooks/stripe/individual
POST /webhooks/stripe/company
```

#### Job 4: AI Chat Integration Service
**Purpose**: Bridge between mobile app and RAGFlow AI service
**Technology**: Node.js with WebSocket support
**Schedule**: Real-time
**Priority**: High

**Implementation Requirements**:
- Message queueing system (Redis)
- Stream handling for AI responses
- Context management for conversations
- Error handling and retry logic
- Response time monitoring

**API Endpoints**:
```
POST /chat/send-message
GET /chat/conversations
POST /chat/new-conversation
DELETE /chat/conversations/:id
GET /chat/history
POST /chat/upload-audio
POST /chat/upload-image
```

#### Job 4: File Storage Service
**Purpose**: Handle image and audio file uploads
**Technology**: Node.js with AWS S3 or similar
**Schedule**: Real-time
**Priority**: Medium

**Implementation Requirements**:
- Multipart file upload handling
- Image compression and optimization
- Audio transcription service integration
- CDN integration for fast delivery
- Automatic cleanup of expired files

**Storage Structure**:
```
/uploads/
  /users/{user_id}/
    /avatars/
    /messages/
      /images/
      /audio/
  /temp/ (auto-cleanup after 24h)
```

#### Job 5: Company Management Service
**Purpose**: Handle company account creation and user management
**Technology**: Node.js/Express
**Schedule**: Real-time
**Priority**: Medium

**Implementation Requirements**:
- Company code generation and validation
- User invitation system
- Role-based access control
- Company statistics dashboard
- Bulk user operations

**API Endpoints**:
```
POST /companies/create
GET /companies/:id
PUT /companies/:id
POST /companies/validate-code
POST /companies/invite-users
GET /companies/:id/users
DELETE /companies/:id/users/:userId
```

### 3.2 Maintenance and Monitoring Jobs

#### Job 6: Database Maintenance
**Purpose**: Regular database cleanup and optimization
**Technology**: SQL scripts with cron scheduling
**Schedule**: Daily/Weekly
**Priority**: Medium

**Tasks**:
```bash
# Daily at 02:00 UTC - Clean up expired messages
0 2 * * * /usr/local/bin/psql -d tgmai -f /app/sql/cleanup-expired-messages.sql

# Weekly on Sunday at 03:00 UTC - Database optimization
0 3 * * 0 /usr/local/bin/psql -d tgmai -f /app/sql/optimize-database.sql

# Monthly - Archive old conversations
0 4 1 * * /usr/local/bin/node /app/jobs/archive-conversations.js
```

#### Job 7: Usage Analytics
**Purpose**: Generate usage statistics and reports
**Technology**: Node.js with database aggregation
**Schedule**: Daily
**Priority**: Low

**Tasks**:
```bash
# Daily at 01:00 UTC - Generate daily usage stats
0 1 * * * /usr/local/bin/node /app/jobs/generate-usage-stats.js

# Weekly - Generate user engagement reports
0 5 * * 1 /usr/local/bin/node /app/jobs/generate-engagement-reports.js
```

#### Job 8: Health Monitoring
**Purpose**: Monitor system health and send alerts
**Technology**: Node.js with monitoring tools
**Schedule**: Every 5 minutes
**Priority**: High

**Tasks**:
```bash
# Every 5 minutes - Health check
*/5 * * * * /usr/local/bin/node /app/jobs/health-check.js

# Every hour - Performance metrics
0 * * * * /usr/local/bin/node /app/jobs/collect-metrics.js
```

#### Job 9: Backup Service
**Purpose**: Regular data backups
**Technology**: Bash scripts with cloud storage
**Schedule**: Daily
**Priority**: High

**Tasks**:
```bash
# Daily at 00:30 UTC - Database backup
30 0 * * * /app/scripts/backup-database.sh

# Daily at 01:00 UTC - File storage backup
0 1 * * * /app/scripts/backup-files.sh
```

#### Job 10: Email Notification Service
**Purpose**: Send transactional emails
**Technology**: Node.js with email service (SendGrid/AWS SES)
**Schedule**: Real-time + batch processing
**Priority**: Medium

**Email Types**:
- Welcome emails
- Password reset
- Subscription notifications
- Usage limit warnings
- Company invitations

**Tasks**:
```bash
# Every 15 minutes - Process email queue
*/15 * * * * /usr/local/bin/node /app/jobs/process-email-queue.js
```

## 4. Infrastructure Requirements

### 4.1 Server Infrastructure

```yaml
# Docker Compose Example - Dual Backend Architecture
version: '3.8'
services:
  # API Gateway (Main Entry Point)
  api-gateway:
    build: ./api-gateway
    ports:
      - "3000:3000"
    environment:
      - REDIS_URL=redis://redis:6379
      - STRAPI_URL=http://strapi:1337
      - POCKETBASE_URL=http://pocketbase:8090
      - RAGFLOW_URL=http://ragflow:8080
    depends_on:
      - redis
      - strapi
      - pocketbase
      - ragflow

  # Strapi CMS (Company Users)
  strapi:
    image: strapi/strapi:latest
    ports:
      - "1337:1337"
    environment:
      - DATABASE_HOST=postgres-strapi
      - DATABASE_NAME=strapi_company
      - DATABASE_USERNAME=strapi_user
      - DATABASE_PASSWORD=strapi_pass
      - JWT_SECRET=strapi-jwt-secret
    depends_on:
      - postgres-strapi

  # PocketBase (Individual Users)
  pocketbase:
    image: ghcr.io/muchobien/pocketbase:latest
    ports:
      - "8090:8090"
    environment:
      - ENCRYPTION_KEY=pocketbase-encryption-key
    volumes:
      - pocketbase_data:/pb_data
    command: 
      - --dir=/pb_data
      - --publicDir=/pb_public

  # PostgreSQL for Strapi (Company Users)
  postgres-strapi:
    image: postgres:14
    environment:
      - POSTGRES_DB=strapi_company
      - POSTGRES_USER=strapi_user
      - POSTGRES_PASSWORD=strapi_pass
    volumes:
      - postgres_strapi_data:/var/lib/postgresql/data

  # Redis for caching and job queues
  redis:
    image: redis:7
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # RAGFlow AI Service
  ragflow:
    image: ragflow/ragflow:latest
    ports:
      - "8080:8080"
    environment:
      - API_KEY=your-ragflow-api-key
      - DATABASE_URL=postgresql://ragflow_user:ragflow_pass@postgres-ragflow:5432/ragflow
    depends_on:
      - postgres-ragflow
    volumes:
      - ragflow_data:/app/data

  # PostgreSQL for RAGFlow
  postgres-ragflow:
    image: postgres:14
    environment:
      - POSTGRES_DB=ragflow
      - POSTGRES_USER=ragflow_user
      - POSTGRES_PASSWORD=ragflow_pass
    volumes:
      - postgres_ragflow_data:/var/lib/postgresql/data

  # Background Job Processor
  job-processor:
    build: ./job-processor
    environment:
      - REDIS_URL=redis://redis:6379
      - STRAPI_URL=http://strapi:1337
      - POCKETBASE_URL=http://pocketbase:8090
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - SENDGRID_API_KEY=${SENDGRID_API_KEY}
    depends_on:
      - redis
      - strapi
      - pocketbase

volumes:
  postgres_strapi_data:
  postgres_ragflow_data:
  pocketbase_data:
  redis_data:
  ragflow_data:
```

### 4.2 Environment Variables

```env
# Dual Backend URLs
STRAPI_URL=https://company-api.yourdomain.com
POCKETBASE_URL=https://individual-api.yourdomain.com
RAGFLOW_URL=https://ai.yourdomain.com
RAGFLOW_API_KEY=your-ragflow-api-key

# Database Configuration
# Strapi PostgreSQL (Company Users)
STRAPI_DATABASE_URL=postgresql://strapi_user:strapi_pass@postgres-strapi:5432/strapi_company

# PocketBase SQLite (Individual Users) - Auto-managed by PocketBase
POCKETBASE_ENCRYPTION_KEY=your-pocketbase-encryption-key

# RAGFlow PostgreSQL
RAGFLOW_DATABASE_URL=postgresql://ragflow_user:ragflow_pass@postgres-ragflow:5432/ragflow

# Redis
REDIS_URL=redis://redis:6379

# Authentication Secrets
STRAPI_JWT_SECRET=your-strapi-jwt-secret
POCKETBASE_JWT_SECRET=your-pocketbase-jwt-secret
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=12

# File Storage
AWS_S3_BUCKET=your-bucket-name
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1

# Payment Processing
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET_INDIVIDUAL=whsec_individual_...
STRIPE_WEBHOOK_SECRET_COMPANY=whsec_company_...

# Email Service
SENDGRID_API_KEY=your-sendgrid-api-key
FROM_EMAIL=noreply@yourdomain.com

# App Configuration
NODE_ENV=production
API_GATEWAY_PORT=3000
STRAPI_PORT=1337
POCKETBASE_PORT=8090
RAGFLOW_PORT=8080
CORS_ORIGIN=https://yourdomain.com

# Company Management
COMPANY_CODE_LENGTH=6
COMPANY_CODE_EXPIRY_DAYS=30
```

## 5. Deployment Schedule

### Phase 1: Core Infrastructure (Week 1-2)
1. Set up API Gateway service for request routing
2. Deploy Strapi CMS for company users with custom content types
3. Deploy PocketBase for individual users with collections
4. Configure PostgreSQL databases for both Strapi and RAGFlow
5. Set up Redis for caching and job queues
6. Deploy RAGFlow AI service

### Phase 2: Authentication and Routing (Week 3-4)
1. Implement dual authentication service (Strapi + PocketBase)
2. Create user type detection and routing logic
3. Set up token validation for both backends
4. Implement company code validation system
5. Configure social login for individual users

### Phase 3: Core Features (Week 5-6)
1. Implement dual subscription management (Individual + Company billing)
2. Set up payment processing with Stripe (dual webhooks)
3. Create file storage service with dual backend support
4. Implement AI chat integration service
5. Set up message and conversation synchronization

### Phase 4: Advanced Features (Week 7-8)
1. Company management system for business accounts
2. Usage analytics for both user types
3. Email notification service
4. Background job processing system

### Phase 5: Monitoring and Optimization (Week 9-10)
1. Health monitoring system for all services
2. Performance optimization and load balancing
3. Backup and disaster recovery for dual databases
4. Load testing and horizontal scaling setup
5. Security audit and penetration testing

## 6. Security Considerations

### Authentication & Authorization
- JWT tokens with short expiration times
- Refresh token rotation
- Rate limiting on all endpoints
- Device fingerprinting for suspicious activity
- Role-based access control (RBAC)

### Data Protection
- Encryption at rest and in transit
- PII data anonymization for analytics
- GDPR compliance for EU users
- Regular security audits
- Secure file upload validation

### API Security
- API key authentication for service-to-service communication
- Request/response validation
- SQL injection protection
- XSS protection
- CORS configuration

## 7. Monitoring and Alerting

### Key Metrics to Track
- API response times
- Database query performance
- Message delivery success rate
- User authentication success/failure rates
- Subscription conversion rates
- File upload success rates

### Alert Configurations
- High error rates (>5% in 5 minutes)
- Database connection issues
- Payment processing failures
- RAGFlow service downtime
- Storage capacity warnings (>80%)

## 8. Scaling Considerations

### Horizontal Scaling
- Load balancers for API servers
- Database read replicas
- Redis clustering
- CDN for static assets
- Microservices architecture

### Performance Optimization
- Database indexing strategy
- Query optimization
- Caching layers (Redis)
- Background job processing
- Asset optimization and compression

This comprehensive backend infrastructure will ensure the TGM HydroAI Chat application can handle production workloads, maintain high availability, and provide excellent user experience while remaining secure and scalable.