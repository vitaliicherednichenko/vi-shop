# frozen_string_literal: true

module Spree
  module Admin
    class ProductImportsController < Spree::Admin::BaseController
      def new
        authorize! :create, Spree::Product
      end

      def create
        authorize! :create, Spree::Product

        sheet_url = params[:sheet_url].to_s.strip

        if sheet_url.blank?
          flash[:error] = Spree.t('admin.product_import.flash.blank_url')
          redirect_to(new_admin_product_import_path) and return
        end

        ProductImportJob.perform_later(sheet_url, store_id: current_store&.id)

        flash[:success] = Spree.t('admin.product_import.flash.queued')
        redirect_to admin_products_path
      end
    end
  end
end
