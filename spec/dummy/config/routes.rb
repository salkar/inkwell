# frozen_string_literal: true

Rails.application.routes.draw do
  mount Inkwell::Engine => "/inkwell"
end
