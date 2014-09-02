(ns studyflow.web
  (:require [ring.util.response :as resp]
            [studyflow.web.api :as api]
            [studyflow.web.authentication :as authentication]
            [studyflow.web.browser-resources :as browser-resources]
            [studyflow.web.caching :refer [wrap-no-cache-dwim]]
            [studyflow.web.handler-tools :refer [combine-ring-handlers]]
            [studyflow.web.status :as status]
            [studyflow.web.start :as start]
            [studyflow.learning.read-model :as m]))

(defn fallback-handler
  [r]
  (resp/not-found (str "Not found.\n" (pr-str r))))

(defn wrap-redirect-urls [handler redirect-urls]
  (fn [req]
    (handler (assoc req :redirect-urls redirect-urls))))

(defn wrap-read-model
  [handler read-model-atom]
  (fn [request]
    (handler (assoc request :read-model @read-model-atom))))

(defn wrap-cookie-domain
  [handler cookie-domain]
  (fn [request]
    (handler (assoc request :cookie-domain cookie-domain))))

(defn catchup-handler
  [{:keys [read-model]}]
  (when-not (m/caught-up? read-model)
    {:status 503
     :body "Server starting up."
     :headers {"Content-Type" "text/plain"}}))


(defn make-request-handler
  [event-store read-model session-store redirect-urls cookie-domain]
  (-> (combine-ring-handlers  browser-resources/resource-handler
                              (-> (combine-ring-handlers
                                   catchup-handler
                                   start/handler
                                   (api/make-request-handler event-store)
                                   (wrap-redirect-urls browser-resources/course-page-handler redirect-urls))
                                  (authentication/wrap-authentication session-store)
                                  (wrap-read-model read-model)
                                  (wrap-redirect-urls redirect-urls)
                                  (wrap-cookie-domain cookie-domain))
                              status/status-handler
                              fallback-handler)
      wrap-no-cache-dwim))
