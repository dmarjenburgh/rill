(ns studyflow.web.handler-tools)

(defn combine-ring-handlers
  [& handlers]
  (fn [r]
    (some #(% r) handlers)))