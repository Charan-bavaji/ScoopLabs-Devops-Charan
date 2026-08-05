# Docker Networking Scenarios (Strict Isolation) - L3

## Objective

Create a secure Docker network architecture where:

- Frontend can communicate only with Backend.
- Backend can communicate with both Frontend and Database.
- Frontend cannot communicate directly with Database.

---

## Network Architecture

```
                 frontend-network
        +-------------------------------+

        +-----------+        +-------------+
        | Frontend  | <----> | Backend API |
        +-----------+        +-------------+
                                   |
                                   |
                                   |
                 backend-network   |
        +--------------------------+
                                   |
                             +-----------+
                             | Database  |
                             +-----------+
```

---

## Services

| Service | Network |
|----------|---------|
| Frontend | frontend-network |
| Backend API | frontend-network + backend-network |
| Database | backend-network |

---

## Security Benefit

Using custom bridge networks isolates containers by default.

The frontend container is connected only to the frontend network, so it has no route or DNS visibility to the database container.

The backend acts as the only communication bridge between the frontend and database, reducing the attack surface and preventing direct database access if the frontend is compromised.

---

## Verification

### Network Creation

Insert Screenshot

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/0e8b48c8-1830-467e-bc8f-db620c2445f2" />


---

### Backend → Database (Success)

Insert Screenshot


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ec59efc6-378d-49a6-8f7d-3cf6735c752c" />


---

### Frontend → Database (Failed)

Insert Screenshot


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/e23c307d-f647-4ee4-9b81-e30aa9590a30" />


---

## Commands Used

```bash
docker compose up -d

docker network ls

docker ps

docker exec -it backend-api sh

ping database

docker exec -it frontend bash

ping database
```

---

## Result

The frontend and database remain isolated, while the backend successfully communicates with both networks, satisfying the required secure three-tier architecture.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2d978217-172b-4d16-b135-00e4ba1bfcdb" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/0b179a17-7d95-4f74-989b-a268153d43fe" />

