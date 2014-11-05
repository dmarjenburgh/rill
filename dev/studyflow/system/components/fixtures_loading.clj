(ns studyflow.system.components.fixtures-loading
  (:require [com.stuartsierra.component :refer [Lifecycle]]
            [ring.mock.request :as ring-mock]
            [clout-link.route :as route]
            [studyflow.learning.web.routes :as routes]
            [clojure.tools.logging :refer [info debug spy]]
            [clojure.java.io :as io]))

(defrecord FixturesLoadingComponent [ring-handler]
  Lifecycle
  (start [component]
    (info "Starting fixtures-loading-component")
    (let [handler (:handler ring-handler)
          materials (slurp (io/resource "dev/20141010-entry-quiz-and-meijerink.json"))
          course-id (let [[_ rest] (.split ^String materials ":")
                          [quoted-id] (.split ^String rest ",")
                          [_ id] (.split ^String quoted-id "\"")]
                      id)
          response (handler (-> (ring-mock/request :put (route/uri-for routes/update-course-material course-id)
                                                   materials)
                                (ring-mock/content-type "application/json")))]
      (when (not= (:status response) 200)
        (throw (Exception. (str "Fixture loading failed for course-material: " response)))))
    component)
  (stop [component]
    (info "Stopping fixtures-loading-component, not removing anything")
    component))

(defn fixtures-loading-component []
  (map->FixturesLoadingComponent {}))