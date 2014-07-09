(ns studyflow.login.credentials
  (:require [clojure.tools.logging :as log]
            [clojure.core.async :refer [<!! thread]]
            [crypto.password.bcrypt :as bcrypt]
            [environ.core :refer [env]]
            [rill.message :as message]
            [studyflow.events.student :as student-events]))

(defonce db (atom {}))

(defn- find-user-by-email [db email]
  (get @db email))

(defn authenticate [db email password]
  (if-let [user (find-user-by-email db email)]
    (if (bcrypt/check password (:encrypted-password user))
      user)))

(defn wrap-authenticator [app db]
  (fn [req]
    (app (assoc req :authenticate (partial authenticate db)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Event sourcing

(defmulti handle-event (fn [_ event] (message/type event)))

(defmethod handle-event ::student-events/Created
  [state event]
  (assoc state (:email event)
         {:uuid (:student-id event)
          :role "student"
          :encrypted-password (:encrypted-password event)}))

(defmethod handle-event :default
  [state _] state)

(defn listen! [channel]
  (thread
    (loop []
      (when-let [event (<!! channel)]
        (swap! db handle-event event)
        (recur)))))
