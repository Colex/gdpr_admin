# frozen_string_literal: true

Rails.application.routes.draw do
  mount GdprAdmin::Engine => '/gdpr_admin'
end
