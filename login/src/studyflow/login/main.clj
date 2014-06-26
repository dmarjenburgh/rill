(ns studyflow.login.main
  (:require [clojure.java.jdbc :as sql]
            [clojure.string :as str]
            [compojure.core :refer [defroutes GET POST]]
            [compojure.route :refer [not-found]]
            [environ.core :refer [env]]
            [hiccup.page :refer [html5 include-css]]
            [hiccup.form :as form]
            [ring.util.response :as response]
            [ring.middleware.session :as session]
            [ring.middleware.anti-forgery :as anti-forgery]
            [ring.middleware.defaults :refer [wrap-defaults site-defaults]]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; View

(def app-title "Studyflow")

(defn layout [title & body]
  (html5
   [:head
    [:title (str/join " - " [app-title title])]
    (include-css "screen.css")]
   [:body
    [:h1 title]
    body]))

(defn home [user-count user-list]
  [:div
   [:h2 "welcome home"]
   [:div
    (str user-count " users registered")]
   [:div
    (str/join " ," user-list)]])

(defn login [email password msg]
  (form/form-to [:post "/login"]
    (form/hidden-field "__anti-forgery-token" anti-forgery/*anti-forgery-token*)
    [:div
      [:p msg]
      [:div
        (form/label "email" "email")
        (form/email-field "email" email)]
      [:div
        (form/label "password" "password")
        (form/password-field "password" password)]
      [:div
        (form/submit-button "login")]]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Model

(defn count-users [db]
  (:count
   (first
    (sql/query db "SELECT COUNT(*) FROM users"))))

(defn list-users [db]
  (let [result  (sql/query db "SELECT * FROM users")]
   (clojure.string/join ", " (map :uuid result) )))

(defn authenticated? [email,password]
  ;; check database
  (and (= email "info@studyflow.nl") (= password "beard")))

(defn persisted? [email]
  ;; check session
  (= 1 2))

(defn persist! [email]
  ;; set session persistent
  (session/wrap-session))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Controller

(defroutes actions
  (GET "/" {db :db}
    (if
      (persisted? "info@studyflow.nl")
        (layout "home" (home (count-users db) (list-users db)))
        (response/redirect "/login")))
  (GET "/login" {db :db}
    (layout "login" (login nil nil "please login")))
  (POST "/login" [email password]
    (if
      (authenticated? email password)
        (response/redirect "/")
        (layout "login" (login email password "wrong email / password combination"))))
  (not-found "Nothing here"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wiring

(defn wrap-db [app db]
  (fn [req]
    (app (assoc req :db db))))

(def db
  {:classname "org.postgresql.Driver"
   :subprotocol "postgresql"
   :subname (or (env :db-subname) "//localhost/studyflow_login")
   :user (or (env :db-user) "studyflow")
   :password (or (env :db-password) "studyflow")})

(defn bootstrap! []
  (sql/execute! db ["CREATE TABLE IF NOT EXISTS users (uuid VARCHAR(36) PRIMARY KEY)"]))

(def app
  (->
   (wrap-defaults actions site-defaults)
   (wrap-db db)))

