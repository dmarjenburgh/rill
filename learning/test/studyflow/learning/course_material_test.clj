(ns studyflow.learning.course-material-test
  (:require [studyflow.learning.course-material :as material]
            [clojure.java.io :as io]
            [clojure.test :refer [is deftest testing]]
            [rill.uuid :refer [new-id]]
            [cheshire.core :as json]
            [studyflow.json-tools :refer [key-from-json]]))

(defn read-example-json
  []
  (json/parse-string (slurp (io/resource "dev/material.json")) key-from-json))

(deftest parsing-test
  (testing "parsing example json"
    (is (= (:name (material/parse-course-material (read-example-json)))
           "Counting")))

  (testing "throws exceptions when not valid"
    (is (thrown? RuntimeException (material/parse-course-material {:id "invalid" :name "Counting"})))))
