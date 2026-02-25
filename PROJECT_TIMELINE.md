## Stackit – 1-Week MVP Project Timeline

### Overview

- **Goal**: Deliver a functional iOS MVP of Stackit that supports authentication, daily task/event scheduling, a priority-based scheduler, notifications, and basic completion metrics.  
- **Duration**: 7 days (one-week sprint).  
- **Owner**: Solo developer.  
- **Constraints**: Use only free tools/services (Xcode, Supabase free tier, etc.).

---

### Milestones (from PRD)

1. **Workflow template setup**  
2. **Event/task fields established**  
3. **Data storage established**  
4. **User login/registration working**  
5. **Priority queueing algorithm set up**  
6. **UI/UX set up**  
7. **Code fixes, cleaning, and debugging**

---

### Day-by-Day Plan

#### Day 1 – Planning & Project Setup
- **Objectives**: Clarify scope, set up the project skeleton, and prepare for rapid development.
- **Tasks**:  
  - Finalize MVP feature list and non-functional requirements (based on PRD).  
  - Create Xcode project for iOS (Swift/SwiftUI).  
  - Set up basic app architecture: navigation structure (e.g., main daily view, task detail view, settings view).  
  - Define high-level data models in code (`User`, `Task`, `DailyMetrics`).  
  - Integrate any essential utilities (logging, basic configuration management).
- **Deliverables**:  
  - Running blank app with basic navigation scaffolding.  
  - Initial Git commit with project skeleton.

#### Day 2 – Data Model & Event/Task Fields
- **Objectives**: Establish in-app data structures and local representations for tasks and events.
- **Tasks**:  
  - Implement Swift models for tasks and events with required fields:  
    - Title, notes, priority, date, start/end time, estimated duration, type, recurrence, completion flags.  
  - Define in-app repositories/services for managing task and event data (even if initially in-memory).  
  - Build simple forms for task/event creation and editing (no backend yet).  
  - Validate that tasks/events can be created, displayed in a list/timeline, edited, and deleted.
- **Deliverables**:  
  - Local-only task/event CRUD working in the app.  
  - Screens: basic task creation/edit UI integrated into navigation.

#### Day 3 – Backend & Data Storage
- **Objectives**: Establish persistent storage and sync for user data.
- **Tasks**:  
  - Set up Supabase (or equivalent) project with necessary tables (Users, Tasks, DailyMetrics).  
  - Integrate Supabase SDK into the iOS app.  
  - Implement data access layer:  
    - Create/read/update/delete tasks for the authenticated user.  
    - Store completion timestamps and daily metrics.  
  - Ensure secure configuration for API keys and environment variables.  
  - Implement basic offline strategy (e.g., local in-memory state that syncs).
- **Deliverables**:  
  - Tasks persist across app installs and device restarts (via backend).  
  - Manual testing: add/edit/complete tasks and see changes reflected after restart.

#### Day 4 – Authentication (Gmail / Apple ID)
- **Objectives**: Enable user login and account separation.
- **Tasks**:  
  - Implement **Sign in with Apple**.  
  - Implement Google sign-in for Gmail accounts (if feasible within time; if not, prioritize Apple sign-in).  
  - Connect auth layer with Supabase (or chosen backend) user records.  
  - Handle login, logout, and basic error states.  
  - Ensure user-specific data isolation (only see own tasks/events).
- **Deliverables**:  
  - Working login flow from app start (if user not authenticated).  
  - Logged-in users can access their own tasks and metrics.  
  - Logged-out state returns to a welcome/login screen.

#### Day 5 – Priority Queueing & Notifications
- **Objectives**: Implement the core scheduling intelligence and basic reminders.
- **Tasks**:  
  - Implement a local priority-based scheduler that:  
    - Filters today’s uncompleted tasks.  
    - Excludes time blocked by fixed events.  
    - Sorts by priority and time to pick “current” and “next” tasks.  
  - Integrate the scheduler into the main daily view (highlight current/next task).  
  - Add local notifications:  
    - Schedule notifications at task start times (or configurable offsets).  
    - Handle notification taps to open the relevant task.  
  - Basic testing of scheduler behavior for different combinations of priorities and times.
- **Deliverables**:  
  - Working “next task” suggestion on main screen.  
  - Notifications firing at correct times and bringing user into app.

#### Day 6 – UI/UX Polish & Rewards View
- **Objectives**: Make the app usable and visually consistent with the minimalistic vision, and add simple rewards/analytics.
- **Tasks**:  
  - Refine the daily view UI: spacing, typography, color usage (minimal, low distraction).  
  - Implement a simple **metrics/reward view** that shows:  
    - Daily completion count.  
    - Daily completion rate (completed vs. total).  
    - Basic streak indicator (consecutive days with at least N tasks completed).  
  - Improve task detail and settings screens (logout, notification toggle, links to privacy policy).  
  - Address UX friction (e.g., number of taps to create and complete a task).
- **Deliverables**:  
  - Visually clean and coherent app aligning with “minimalistic and low distraction” goals.  
  - Basic reward/analytics section accessible from main navigation.

#### Day 7 – Testing, Fixes, and Hardening
- **Objectives**: Stabilize the MVP, fix critical issues, and prepare for handoff or internal release.
- **Tasks**:  
  - Manual testing of all core flows:  
    - New user signup and login.  
    - Task/event creation, editing, deletion, and completion.  
    - Priority-based “next task” behavior.  
    - Notifications sending and handling.  
    - Metrics and rewards display.  
  - Fix high and medium-severity bugs.  
  - Clean up code: remove dead code, improve structure where low effort.  
  - Review performance and address any obvious bottlenecks.  
  - Update `README` with basic setup/run instructions (if time).
- **Deliverables**:  
  - Stable MVP build suitable for internal testing or TestFlight submission (App Store submission steps may be beyond week scope).  
  - Short list of known issues and follow-up enhancements.

---

### Risk Management Within Timeline

- **Auth integration risk**: If Google sign-in is too time-consuming, prioritize Apple sign-in for MVP and mark Google sign-in as a post-MVP enhancement.  
- **Backend complexity risk**: If Supabase integration slows progress, consider initially shipping with local-only persistence and adding backend sync in a follow-up iteration.  
- **Notification limitations**: If fine-grained scheduling is delayed, start with simple “task start” reminders and refine later.

---

### Checkpoints & Review

- **Mid-sprint checkpoint (End of Day 3–4)**:  
  - Confirm that basic data storage and at least one auth method are functioning.  
  - If behind schedule, de-scope lower-priority features (e.g., streaks, recurrence) to protect core scheduling and notifications.

- **Pre-release checkpoint (End of Day 6)**:  
  - Core flows working end-to-end with acceptable UX.  
  - Only non-critical bugs remain for Day 7.

