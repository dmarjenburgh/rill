(ns studyflow.learning.web.start
  (:require [studyflow.learning.web.routes :as routes]
            [clout-link.route :refer [handle uri-for]]
            [studyflow.learning.read-model :refer [get-course-name]]
            [ring.util.response :refer [redirect-after-post]]
            [clojure.tools.logging :as log]))


(def handler
  (handle routes/get-start
          (fn [{model :read-model}]
            (redirect-after-post (uri-for routes/get-course-page (get-course-name model))))))
