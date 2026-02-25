## Stackit – Product Requirements Document (PRD)

### 1. Executive Summary

**Product Vision**  
Stackit is a minimalistic daily scheduler and task tracker for iOS that prioritizes what users should do next, inspired by operating system process schedulers. It is designed for young adults with hectic schedules who suffer from decision fatigue and over-choice, helping them move through their day with clear, context-aware next actions rather than an overwhelming list. The app combines a simple, low-distraction interface, a priority-based scheduling engine, and a light reward system to encourage consistent task completion. Success is primarily measured by daily task completion rates, frequency of app usage, and user retention over time.

**Strategic Alignment**  
- **Business objectives supported**:  
  - **Promote productivity** for young adults by increasing completed tasks per day.  
  - **Drive user growth and retention** through habitual daily use driven by reminders and rewards.  
  - **Enable future monetization** via premium features (advanced analytics, custom themes, integrations), once a strong active user base is established.
- **User problems solved**:  
  - **Decision fatigue / over-choice** when deciding what to work on next.  
  - **Lack of direction** at the start and in the middle of the day, leading to idle time and procrastination.  
  - **Difficulty remembering events/tasks** scattered across calendars, notes apps, and to‑do lists.
- **Market opportunity**:  
  - Growing population of young professionals and students with fragmented attention and busy schedules.  
  - Existing tools tend to be either too complex, visually noisy, or undirected; Stackit emphasizes **minimalism + clear next task** as its core differentiator.
- **Competitive advantage**:  
  - **Minimalistic, low-distraction UI** that surfaces only what matters “right now”.  
  - **Priority-based scheduler** that merges fixed calendar events with user-defined tasks and priorities.  
  - **Lightweight, privacy-conscious, and fast** iOS experience designed to be shipped quickly and iterated on.

**Strategic Priority**  
- **Priority: High**  
  - Reasoning: Tackles a common, acute productivity problem in a large and growing segment (young adults, students, early professionals).  
  - The feature set is scoped for a one-week MVP sprint, enabling fast validation and iteration with minimal dependencies.  
  - Strong alignment with goals of user growth, engagement, and a clear path to future monetization.

**Resource Requirements**  
- **Development effort estimate (MVP)**:  
  - ~40–50 hours of focused solo development for a functional MVP: authentication, core scheduling, tasks, notifications, and basic analytics.  
- **Timeline & key milestones (1 week MVP)**:  
  1. **Workflow template setup** – Define navigation, main screens, and core data models.  
  2. **Event/task fields established** – Implement data structures for tasks/events (priority, time, notes, recurrence, etc.).  
  3. **Data storage established** – Integrate a backend (e.g., Supabase) for user data, tasks, and metrics.  
  4. **User login/registration working** – Implement login with Gmail and/or Apple ID.  
  5. **Priority queueing algorithm set up** – Implement core scheduling logic that chooses next task based on priority and time.  
  6. **UI/UX implemented** – Minimalistic, distraction-free daily agenda and task views.  
  7. **Code fixes, cleaning, and debugging** – Stabilize MVP, fix critical bugs, and ensure acceptable performance.  
- **Team members**:  
  - Solo developer (also acting as product owner for MVP).  
- **Budget and resource allocation**:  
  - All required services should be **free or on free tiers** (Xcode, Supabase free tier, Apple’s free development tools; note that App Store distribution will have separate costs outside MVP scope).

---

### 2. Problem Statement & Opportunity

**Problem Definition**  
- **User pain points (detailed)**:  
  - Users with hectic schedules struggle to decide **what to do next** when faced with many competing tasks and events.  
  - Idle decision windows (e.g., after completing a task, between meetings, or at the start of the day) often expand into procrastination because there is no clear, prioritized next action.  
  - Existing calendar or to‑do apps often present **long, flat lists** or busy calendars that require active scanning and choosing, increasing decision fatigue.  
  - Users fail to consistently track progress or derive motivation from seeing their productivity improve.
- **Quantified impact of current problems (estimates)**:  
  - Task switching and idle time between tasks can waste **upwards of 2 hours per day** for users frequently interrupted or unsure what to do next.  
  - Corporate and productivity studies show that interruptions (e.g., email, notifications) significantly degrade focus and extend time-to-completion for tasks; with modern social media usage, this impact is likely worse.  
  - For our users, even a **30–60 minute productivity gain per day** is meaningful and highly valuable.
- **Evidence supporting problem existence**:  
  - Studies show workers lose significant time recovering from interruptions (e.g., email and notification-driven disruptions).  
  - Anecdotal evidence from knowledge workers and students that “choosing what to do” is itself mentally exhausting.  
  - The rising popularity of productivity tools, time-blocking, and habit trackers indicates strong demand for solutions in this space.

**Opportunity**  
- Build an iOS-first, minimalistic scheduling tool that:  
  - Offloads **decision-making about what to do next** to a priority-based engine.  
  - Integrates with or coexists alongside existing calendar events.  
  - Keeps users in a **tight cycle of action → completion → feedback/reward → next action**.  
- Fast MVP delivery within one week enables early user testing, feedback collection, and prioritization for subsequent releases (e.g., integrations, more advanced analytics, personalization).

**Success Criteria**
- **Primary success metrics**:  
  - **Daily Active Users (DAU)** and **7-day retention** for early cohorts.  
  - **Average daily task completion count** per active user.  
  - **Daily completion rate**: completed tasks / total scheduled tasks.  
- **Secondary metrics**:  
  - Time from app open to first task started (lower is better).  
  - Percentage of users who complete at least one task on their **first day**.  
  - Number of days per week a user logs at least one completed task.  
  - Engagement with reward/analytics views (indicating motivation and perceived value).  
- **Expected user behavior changes**:  
  - Users begin their day by opening Stackit to plan or confirm their day’s tasks.  
  - Users rely on notifications and the “next task” view rather than scanning long lists.  
  - Over time, users feel less overwhelmed by their to‑do list and report improved productivity.

---

### 3. Scope

**In-Scope for MVP (1-week build)**
- iOS application with the following capabilities:  
  - User authentication via Gmail and/or Apple ID.  
  - Simple daily view of today’s schedule (tasks + fixed events).  
  - Ability to add, edit, and complete tasks with key attributes.  
  - Basic handling of fixed (non-editable) events such as meetings or classes (manual entry for MVP; calendar integration is future scope).  
  - Priority-based selection of “current/next task” based on user-defined priorities and time.  
  - Basic notification system to remind users of upcoming or current tasks.  
  - Storage of tasks, events, user data, and completion metrics in a backend such as Supabase.  
  - Simple reward/feedback view (e.g., daily completion percentage, streaks).

**Out of Scope for MVP**
- Full calendar integrations (Google Calendar, Apple Calendar).  
- Collaboration features (shared tasks, team boards).  
- Advanced analytics dashboards or exports.  
- Complex gamification (badges, levels, social leaderboards).  
- Android app, web app, or cross-platform support.

---

### 4. Functional Requirements

#### 4.1 User Accounts & Authentication

**FR-1: User registration & login**
- **Description**: Users can create and access their accounts using Gmail and/or Apple ID, enabling secure, personalized data storage.  
- **Requirements**:  
  - Support “Sign in with Apple”.  
  - Support Google sign-in using Gmail accounts.  
  - Securely associate user identity with a unique user record in the backend.  
  - Persist logged-in state across app launches until explicit logout or token expiration.  
- **Priority**: Must Have (MVP)

**FR-2: Account Management (basic)**
- **Description**: Users can log out and clear local data; basic account state handling.  
- **Requirements**:  
  - Provide a settings screen with a logout option.  
  - On logout, clear locally cached user data and tokens.  
- **Priority**: Must Have (MVP)

---

#### 4.2 Tasks & Events Management

**FR-3: Task creation & editing**
- **Description**: Users can create tasks with associated metadata.  
- **Task fields (initial set)**:  
  - Title (required).  
  - Description / notes (optional).  
  - Priority (e.g., High / Medium / Low or numeric 1–5).  
  - Time attributes:  
    - Due time or time window (e.g., start and end time).  
    - Estimated duration (optional but recommended).  
  - Type: task vs. event (event typically fixed in time).  
  - Recurrence (optional; basic recurring tasks, e.g., daily/weekly).  
- **Requirements**:  
  - Users can create, view, edit, and delete tasks.  
  - Tasks default to “today” if no date selected (configurable later).  
- **Priority**: Must Have (MVP)

**FR-4: Fixed and recurring events**
- **Description**: Users can add fixed events that behave as anchors in the schedule (e.g., classes, meetings).  
- **Requirements**:  
  - Events have fixed start and end times and cannot be auto-moved by the scheduler.  
  - Optional recurrence (e.g., repeats every weekday).  
  - Events appear in the daily schedule alongside tasks.  
- **Priority**: Must Have (MVP)

**FR-5: Task completion & tracking**
- **Description**: Users can mark tasks as completed, feeding into analytics and rewards.  
- **Requirements**:  
  - Users can mark a task as complete from the task details view and from the main daily view.  
  - Completed tasks are visually distinguished from pending tasks.  
  - Completion timestamps are stored for analytics and reward calculations.  
- **Priority**: Must Have (MVP)

---

#### 4.3 Priority-Based Scheduling Engine

**FR-6: Priority queueing logic**
- **Description**: The system suggests the “current” and “next” task by combining priority, time, and existing events.  
- **Core behavior (MVP)**:  
  - Consider all tasks that are not completed and belong to today.  
  - Filter tasks whose scheduled time window overlaps with “now” or the near future.  
  - Rank tasks primarily by priority, secondarily by time proximity (e.g., earliest due first).  
  - Exclude time slots blocked by fixed events.  
  - Return the highest-ranked task as the “current” suggestion; show a small list of upcoming tasks.  
- **Requirements**:  
  - The scheduling algorithm should run locally on the device for speed and privacy.  
  - Provide a deterministic, explainable logic that can be iterated on later (e.g., not ML-based in MVP).  
- **Priority**: Must Have (MVP)

**FR-7: Idle state handling**
- **Description**: At the start of each day (or when no tasks are scheduled), the app should guide the user to set up their day.  
- **Requirements**:  
  - If the user has no tasks for today, display an “empty/idle state” encouraging users to add tasks and events.  
  - Optionally suggest a simple template (e.g., “Morning Deep Work”, “Errands”, “Workout”) to help them get started quickly.  
- **Priority**: Should Have (if time permits in MVP)

---

#### 4.4 Notifications & Reminders

**FR-8: Upcoming task notifications**
- **Description**: Users receive notifications reminding them of tasks at appropriate times.  
- **Requirements**:  
  - Local notifications scheduled for:  
    - Task start time (or a configurable offset before start).  
    - Optional reminder when a high-priority task is overdue.  
  - Tapping a notification opens the app and focuses on the relevant task.  
- **Priority**: Must Have (MVP)

**FR-9: Scheduler-driven prompts**
- **Description**: When a user completes a task, the app should prompt them with the next suggested task.  
- **Requirements**:  
  - After marking a task complete, show the next recommended task with a one-tap “Start” or “Go to task” action.  
  - This may also trigger a subtle in-app notification rather than a system-level notification.  
- **Priority**: Should Have (MVP)

---

#### 4.5 Rewards & Analytics

**FR-10: Daily completion metrics**
- **Description**: Users can see simple, motivating metrics about their daily performance.  
- **Requirements**:  
  - Show daily completion rate: completed tasks / total tasks for the day.  
  - Show count of tasks completed today.  
  - Optional simple visualization (e.g., progress ring or bar).  
- **Priority**: Must Have (MVP)

**FR-11: Streaks / reward feedback**
- **Description**: Provide lightweight reward signals for consistent usage.  
- **Requirements**:  
  - Track and display a basic “daily completion streak” (number of consecutive days with at least N tasks completed).  
  - Provide positive reinforcement after completing tasks and maintaining streaks (e.g., short message, subtle animation).  
- **Priority**: Should Have (MVP)

---

#### 4.6 UI / UX

**FR-12: Minimalistic daily view**
- **Description**: Primary screen shows only what is essential for today.  
- **Requirements**:  
  - Display:  
    - Today’s date.  
    - Current/next task prominently.  
    - List or timeline of today’s tasks and events.  
  - Use a clean, low-color, low-clutter design.  
  - Avoid unnecessary navigation elements or dense iconography.  
- **Priority**: Must Have (MVP)

**FR-13: Task & event detail view**
- **Description**: Tapping a task/event opens a detail view.  
- **Requirements**:  
  - Show all fields (title, notes, priority, time, recurrence, completion state).  
  - Enable editing and deletion from the detail view.  
- **Priority**: Must Have (MVP)

**FR-14: Settings & account view**
- **Description**: Basic settings area to manage account and app-level options.  
- **Requirements**:  
  - Logout option.  
  - Basic notification toggle (on/off).  
  - Links to privacy policy and terms (web URLs).  
- **Priority**: Must Have (MVP)

---

### 5. Non-Functional Requirements

**NFR-1: Performance**
- The app must feel **lightweight and responsive** on recent iOS devices.  
- Initial app load to main screen should be under ~2 seconds on a typical device with network access.  
- Priority scheduling operations should complete within 200ms on average for a typical day’s set of tasks (<100 tasks).

**NFR-2: Availability & Reliability**
- The core scheduling and task management should be available offline (local cache), syncing with the backend when a connection is available.  
- User-critical actions (task add/complete) should be resilient to transient network issues (e.g., queue for sync).

**NFR-3: Security & Privacy**
- Follow modern iOS security best practices for authentication and secure storage of tokens.  
- All communication with backend services (e.g., Supabase) must use HTTPS.  
- Implement and surface an understandable **privacy policy**, clarifying how user data is used and stored.  
- Use anonymized identifiers where possible for analytics; avoid storing unnecessary personally identifiable information (PII).

**NFR-4: Platform Requirements**
- iOS-only MVP, targeting a recent stable iOS version (e.g., iOS 17+).  
- Implemented using Swift and SwiftUI (or UIKit if necessary), built in Xcode, following Apple Human Interface Guidelines where applicable.

---

### 6. Technical Context & Architecture

**Current Architecture (target)**
- **Client**: iOS app built with Swift/SwiftUI.  
- **Backend**: Hosted backend such as Supabase for:  
  - Authentication (supporting Google, Apple ID where feasible).  
  - Storage of user profiles, tasks, events, and completion metrics.  
  - Optional server-side logging/analytics.  
- **Scheduling Engine**: Runs on-device within the iOS app to reduce latency and maintain user privacy.

**Technical Dependencies**
- Xcode and Apple’s iOS SDKs.  
- Supabase (or equivalent) SDK for Swift for database and auth integration.  
- iOS Notification framework for local notifications.  

**Data Model (MVP, high level)**
- **User**: `id`, `auth_provider`, `email` (if available), `created_at`.  
- **Task**: `id`, `user_id`, `title`, `notes`, `priority`, `date`, `start_time`, `end_time`, `estimated_duration`, `type` (task/event), `recurrence_rule`, `completed`, `completed_at`, `created_at`, `updated_at`.  
- **Daily Metrics**: `user_id`, `date`, `total_tasks`, `completed_tasks`, `streak_length` (computed or stored).

---

### 7. Analytics & Success Measurement

**Core Metrics to Track**
- User-level:  
  - DAU, WAU.  
  - 1-day, 7-day, and 30-day retention.  
  - Days per week with at least one completed task.  
- Task-level:  
  - Average number of tasks created per day per active user.  
  - Average number of tasks completed per day per active user.  
  - Completion rate per day (completed vs. scheduled).  
- Feature engagement:  
  - Frequency of opening the reward/analytics view.  
  - Notification open rates (if tracked).

**Success Benchmarks for MVP Validation (indicative)**
- At least **50%** of early users complete 1+ task on day 1.  
- At least **30–40%** 7-day retention among initial test users.  
- Average of **3+ tasks completed per active day** for engaged users.

---

### 8. Risks & Assumptions

**Key Risks**
- Authentication integration complexity (Apple, Google) may exceed 1-week MVP timeline.  
- Notification permissions may be declined by a significant portion of users, reducing impact of reminders.  
- Users may require more customization or integrations (e.g., calendars) than MVP provides, affecting perceived value.

**Assumptions**
- Target users have compatible iOS devices and are comfortable with app-based scheduling.  
- Free tiers of backend services (e.g., Supabase) will be sufficient for early testing.  
- Users understand and accept basic data collection for analytics when clearly communicated.

---

### 9. Future Enhancements (Post-MVP)

- Calendar integration (Google/Apple Calendar).  
- More advanced priority logic (context, location, energy level).  
- Deeper gamification (badges, levels, optional social features).  
- Cross-platform expansion (Android, web).  
- Advanced analytics (time-of-day productivity, category breakdowns, exports).

