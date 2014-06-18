(ns user
  (:require [clojure.tools.logging :refer [info debug spy]]
            [studyflow.system :as sys]
            [com.stuartsierra.component :as component]
            [clojure.test :as test :refer [run-all-tests]]
            [clojure.tools.trace :refer [trace trace-ns]]
            [clojure.tools.namespace.repl :refer (refresh)])
  (:import [org.apache.log4j Logger]))

;; from cascalog playground for swank/slime
(defn bootstrap-emacs []
  (let [logger (Logger/getRootLogger)]
    (doto (. logger (getAppender "stdout"))
      (.setWriter *out*))
    (alter-var-root #'clojure.test/*test-out* (constantly *out*))
    (info "Logging to repl")))

(defonce system nil)

(defn init []
  (alter-var-root #'system (constantly (sys/prod-system sys/prod-config))))

(defn start []
  (bootstrap-emacs)
  (alter-var-root #'system component/start)
  :started)

(defn stop []
  (alter-var-root #'system
                  (fn [s]
                    (info "stopping system")
                    (info "system is" s)
                    (when s
                      (component/stop s)))))

(defn go []
  (if system
    "System not nil, use (reset) ?"
    (do (bootstrap-emacs)
        (init)
        (start))))

(defn reset []
  (stop)
  (refresh :after 'user/go))
