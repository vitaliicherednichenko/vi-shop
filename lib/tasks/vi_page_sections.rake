namespace :vi do
  namespace :page_sections do
    desc 'Seed the homepage with Vi theme page sections (idempotent)'
    task seed: :environment do
      theme = Spree::Store.default.default_theme || Spree::Store.default.themes.first
      abort 'No theme found for the default store' if theme.nil?

      page = theme.pages.find_by(type: 'Spree::Pages::Homepage')
      abort "Homepage not found on theme '#{theme.name}'" if page.nil?

      sections = [
        Spree::PageSections::FullscreenBanner,
        Spree::PageSections::CollectionSlider,
        Spree::PageSections::ImageSlider,
        Spree::PageSections::ImageGrid,
        Spree::PageSections::RiskReducers
      ]

      sections.each_with_index do |klass, idx|
        if page.sections.exists?(type: klass.name)
          puts "SKIP  #{klass.name} (already exists on #{page.name})"
          next
        end

        klass.create!(pageable: page, position: idx + 1)
        puts "CREATE #{klass.name} -> #{page.name} (position #{idx + 1})"
      end
    end

    desc 'Remove all Vi theme page sections from the homepage'
    task reset: :environment do
      theme = Spree::Store.default.default_theme || Spree::Store.default.themes.first
      abort 'No theme found for the default store' if theme.nil?

      page = theme.pages.find_by(type: 'Spree::Pages::Homepage')
      abort "Homepage not found on theme '#{theme.name}'" if page.nil?

      types = %w[
        Spree::PageSections::FullscreenBanner
        Spree::PageSections::CollectionSlider
        Spree::PageSections::ImageSlider
        Spree::PageSections::ImageGrid
        Spree::PageSections::RiskReducers
      ]

      removed = page.sections.where(type: types).destroy_all
      puts "Removed #{removed.size} section(s) from #{page.name}"
    end
  end

  namespace :page_blocks do
    COLLECTION_SLIDER_BLOCKS = 3
    IMAGE_GRID_BLOCKS = 3

    desc 'Ensure ImageCollectionSlider and ImageGridBlock blocks exist on their sections (idempotent)'
    task seed: :environment do
      theme = Spree::Store.default.default_theme || Spree::Store.default.themes.first
      abort 'No theme found for the default store' if theme.nil?

      page = theme.pages.find_by(type: 'Spree::Pages::Homepage')
      abort "Homepage not found on theme '#{theme.name}'" if page.nil?

      collection_section = page.sections.find_by(type: 'Spree::PageSections::CollectionSlider')
      if collection_section
        existing = collection_section.blocks.where(type: 'Spree::PageBlocks::ImageCollectionSlider').count
        missing = COLLECTION_SLIDER_BLOCKS - existing
        missing.times do
          Spree::PageBlocks::ImageCollectionSlider.create!(
            section: collection_section,
            preferred_title: Spree.t('page_sections.image_collection_slider.title_default'),
            preferred_text: Spree.t('page_sections.image_collection_slider.text_default')
          )
          puts "CREATE Spree::PageBlocks::ImageCollectionSlider -> CollectionSlider##{collection_section.id}"
        end
        puts "SKIP  ImageCollectionSlider (already #{existing} present)" if missing <= 0
      else
        puts 'WARN  CollectionSlider section not found — run vi:page_sections:seed first'
      end

      grid_section = page.sections.find_by(type: 'Spree::PageSections::ImageGrid')
      if grid_section
        existing = grid_section.blocks.where(type: 'Spree::PageBlocks::ImageGridBlock').count
        missing = IMAGE_GRID_BLOCKS - existing
        missing.times do
          Spree::PageBlocks::ImageGridBlock.create!(
            section: grid_section,
            preferred_title: Spree.t('page_sections.image_grid.title_default'),
            preferred_text: Spree.t('page_sections.image_grid.text_default')
          )
          puts "CREATE Spree::PageBlocks::ImageGridBlock -> ImageGrid##{grid_section.id}"
        end
        puts "SKIP  ImageGridBlock (already #{existing} present)" if missing <= 0
      else
        puts 'WARN  ImageGrid section not found — run vi:page_sections:seed first'
      end
    end

    desc 'Refresh title/text on existing blocks from current translations'
    task refresh: :environment do
      theme = Spree::Store.default.default_theme || Spree::Store.default.themes.first
      abort 'No theme found for the default store' if theme.nil?

      page = theme.pages.find_by(type: 'Spree::Pages::Homepage')
      abort "Homepage not found on theme '#{theme.name}'" if page.nil?

      mapping = {
        'Spree::PageBlocks::ImageCollectionSlider' => 'image_collection_slider',
        'Spree::PageBlocks::ImageGridBlock'        => 'image_grid'
      }

      Spree::PageBlock.where(section: page.sections, type: mapping.keys).find_each do |block|
        scope = mapping.fetch(block.class.name)
        block.update!(
          preferred_title: Spree.t("page_sections.#{scope}.title_default"),
          preferred_text:  Spree.t("page_sections.#{scope}.text_default")
        )
        puts "UPDATE #{block.class.name}##{block.id} (#{scope})"
      end
    end

    desc 'Remove ImageCollectionSlider and ImageGridBlock blocks from their sections'
    task reset: :environment do
      theme = Spree::Store.default.default_theme || Spree::Store.default.themes.first
      abort 'No theme found for the default store' if theme.nil?

      page = theme.pages.find_by(type: 'Spree::Pages::Homepage')
      abort "Homepage not found on theme '#{theme.name}'" if page.nil?

      removed = Spree::PageBlock.
                  where(section: page.sections).
                  where(type: %w[Spree::PageBlocks::ImageCollectionSlider Spree::PageBlocks::ImageGridBlock]).
                  destroy_all

      puts "Removed #{removed.size} block(s)"
    end
  end

  desc 'Seed both sections and blocks for the Vi theme'
  task seed_all: ['vi:page_sections:seed', 'vi:page_blocks:seed']
end
