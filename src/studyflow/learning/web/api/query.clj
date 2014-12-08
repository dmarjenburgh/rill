(ns studyflow.learning.web.api.query
  (:require [clojure.tools.logging :refer [debug info]]
            [clout-link.route :as clout]
            [rill.uuid :refer [uuid]]
            [studyflow.learning.read-model.queries :as queries]
            [studyflow.learning.read-model :as read-model]
            [studyflow.web.handler-tools :refer [combine-ring-handlers]]
            [studyflow.learning.web.routes :as routes]
            [clj-time.coerce :refer [to-local-date]]
            [clj-time.core :refer [now]]))

(def handler
  "This handler returns data for the json api (or nil)"
  (combine-ring-handlers
   (clout/handle routes/query-course-material
                 (fn [{model :read-model {:keys [course-id student-id]} :params}]
                   (debug "Query handler for " course-id "with model: " model)
                   (if-let [course  (queries/course-material model (uuid course-id) (uuid student-id))]
                     {:status 200 :body course}
                     {:status 400})))
   (clout/handle routes/query-section
                 (fn [{model :read-model {:keys [course-id section-id]} :params}]
                   (debug "Query handler for " course-id " and " section-id "with model: " model)
                   (if-let [section (queries/section model (uuid course-id) (uuid section-id))]
                     {:status 200 :body section}
                     {:status 400})))
   (clout/handle routes/query-question
                 (fn [{model :read-model {:keys [course-id section-id question-id]} :params}]
                   (debug "Query handler for " course-id ", " section-id " and " question-id "with model: " model)
                   (if-let [question (queries/question model (uuid course-id) (uuid section-id) (uuid question-id))]
                     {:status 200 :body question}
                     {:status 200 :body {:id question-id
                                         :tag-tree {:tag "div" :attrs nil :content "Deze vraag is verwijderd door onze redactie. Ga lekker verder, als je hem nog moest beantwoorden keuren we hem goed!"}}})))

   (clout/handle routes/query-chapter-quiz-question
                 (fn [{model :read-model {:keys [course-id chapter-id question-id]} :params}]
                   (debug "Query handler for " course-id ", " chapter-id " and " question-id "with model")
                   (if-let [question (queries/chapter-quiz-question model (uuid course-id) (uuid chapter-id) (uuid question-id))]
                     {:status 200 :body question}
                     {:status 200 :body {:id question-id
                                         :tag-tree {:tag "div" :attrs nil :content "Deze vraag is verwijderd door onze redactie. Ga lekker verder, als je hem nog moest beantwoorden keuren we hem goed!"}}})))

   (clout/handle routes/query-leaderboard
                 (fn [{model :read-model {:keys [course-id student-id]} :params}]
                   {:status 200 :body {:leaderboard (queries/leaderboard model (uuid course-id) (uuid student-id))}}))))
