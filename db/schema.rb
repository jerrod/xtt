# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081003200545) do

  create_table "bj_config", :primary_key => "bj_config_id", :force => true do |t|
    t.string "hostname"
    t.string "key"
    t.text   "value"
    t.string "cast"
  end

  add_index "bj_config", ["hostname", "key"], :name => "index_bj_config_on_hostname_and_key"

  create_table "bj_job", :primary_key => "bj_job_id", :force => true do |t|
    t.text     "command"
    t.string   "state"
    t.integer  "priority"
    t.string   "tag"
    t.integer  "is_restartable"
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status"
  end

  create_table "bj_job_archive", :primary_key => "bj_job_archive_id", :force => true do |t|
    t.text     "command"
    t.string   "state"
    t.integer  "priority"
    t.string   "tag"
    t.integer  "is_restartable"
    t.text     "submitter"
    t.text     "runner"
    t.integer  "pid"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.text     "env"
    t.text     "stdin"
    t.text     "stdout"
    t.text     "stderr"
    t.integer  "exit_status"
  end

  create_table "campfires", :force => true do |t|
    t.string   "domain"
    t.string   "login"
    t.string   "password"
    t.string   "room"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contexts", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  add_index "contexts", ["permalink"], :name => "index_contexts_on_permalink"

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "help", :force => true do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.string   "email"
    t.string   "project_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitations", ["code"], :name => "index_invitations_on_code"

  create_table "memberships", :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.string  "code"
    t.integer "context_id"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.binary  "server_url"
    t.string  "handle"
    t.binary  "secret"
    t.integer "issued"
    t.integer "lifetime"
    t.string  "assoc_type"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.string  "nonce"
    t.integer "created"
  end

  create_table "open_id_authentication_settings", :force => true do |t|
    t.string "setting"
    t.binary "value"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "code"
    t.string   "permalink"
    t.string   "git_repo"
  end

  add_index "projects", ["code"], :name => "index_projects_on_code"
  add_index "projects", ["permalink"], :name => "index_projects_on_permalink"

  create_table "statuses", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "hours",       :precision => 8, :scale => 2, :default => 0.0
    t.string   "message"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.string   "source",                                    :default => "the web"
    t.datetime "finished_at"
  end

  add_index "statuses", ["created_at", "user_id"], :name => "index_statuses_on_created_at_and_user_id"

  create_table "tendrils", :force => true do |t|
    t.integer  "project_id"
    t.string   "notifies_type"
    t.integer  "notifies_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.boolean  "admin",                                   :default => false
    t.integer  "last_status_project_id"
    t.integer  "last_status_id"
    t.string   "last_status_message"
    t.datetime "last_status_at"
    t.string   "time_zone"
    t.string   "aim_login"
    t.string   "identity_url"
    t.string   "permalink"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["identity_url"], :name => "index_users_on_identity_url"
  add_index "users", ["permalink"], :name => "index_users_on_permalink"

end
