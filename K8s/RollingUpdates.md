# Kubernetes Assignment - Rolling Updates

## Concept Task: Explain a rolling update strategy

A rolling update is how a Deployment safely updates Pods (e.g. a new image version) without taking the application down. Instead of killing all old Pods and starting all new ones at once — which would cause a full outage during the switch — Kubernetes replaces Pods gradually, a few at a time.

The default behavior is controlled by two settings:
- **maxSurge**: how many extra Pods above the desired replica count are allowed to be created during the update (default 25%)
- **maxUnavailable**: how many Pods are allowed to be unavailable at once during the update (default 25%)

The actual sequence: Kubernetes brings up a new Pod with the updated image, waits until it passes its readiness check (i.e. it's actually healthy and able to serve traffic), then terminates one old Pod. This repeats one batch at a time until every old Pod has been replaced. At no point does the total count of healthy, serving Pods drop below what's needed to keep the app available.

If something goes wrong mid-rollout, the Deployment also keeps a revision history, so it can be rolled back to the last known-good version with `kubectl rollout undo`.

**In short**: a rolling update trades a bit of extra time for zero downtime — the app keeps serving traffic the entire time the update is happening.

## Hands-on Task: Update the image and check rollout status

Command used:
```
kubectl set image deployment/nginx-deployment nginx=nginx:1.26
```
(Using 1.25 → 1.26 here rather than 1.14 → 1.16, since those are actively maintained nginx versions. Substitute any two valid nginx tags if a specific pair is required.)

Check the rollout status:
```
kubectl rollout status deployment/nginx-deployment
```

Optional, to watch it happen live:
```
kubectl get pods -w
```

During the update, a new Pod comes up with the updated image, passes its readiness check, then an old Pod terminates — this repeats one batch at a time until all Pods are updated. `kubectl rollout status` confirms once the Deployment finishes ("successfully rolled out").

## Submission

- Command used: `kubectl set image deployment/nginx-deployment nginx=nginx:1.26`
- Screenshot: `kubectl rollout status deployment/nginx-deployment` showing the successful rollout confirmation
