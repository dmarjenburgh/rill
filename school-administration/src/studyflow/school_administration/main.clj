(ns studyflow.school-administration.main
  (:require [clojure.tools.logging :as log]
            [studyflow.school-administration.system :as system]
            [com.stuartsierra.component :as component])
  (:gen-class))

(defn -main [jetty-port event-store-uri]
  (log/info "Studyflow school administration app")
  (let [s (-> (system/prod-system {:port (Long/parseLong jetty-port)
                                   :secure-site-defaults? true
                                   :event-store-config event-store-uri})
              component/start)]
    (.addShutdownHook (Runtime/getRuntime)
                      (Thread. (fn []
                                 (component/stop s)
                                 (log/info "Stopping is done, bye"))))))
