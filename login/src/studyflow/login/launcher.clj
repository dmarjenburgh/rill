(ns studyflow.login.launcher
  (:gen-class)
  (:require [studyflow.login.system :as system]
            [com.stuartsierra.component :as component]))

(defn -main [jetty-port publishing-url learning-url session-max-age & [cookie-domain]]
  (let [system (system/make-system {:jetty-port (Long/parseLong jetty-port)
                                    :default-redirect-paths {"editor" publishing-url
                                                             "student" learning-url}
                                    :session-max-age (Long/parseLong session-max-age)
                                    :cookie-domain cookie-domain})]
    (component/start system)))
