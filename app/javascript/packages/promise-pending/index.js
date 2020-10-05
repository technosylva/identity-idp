const pending = new WeakMap();

export function track(promise) {
  pending.set(promise, true);
  promise.then(() => pending.delete(promise));
}

export function isPending(promise) {
  return pending.has(promise);
}
