class ContactsController < ApplicationController
	before_filter :authenticate_user!

	def index

	#    begin
	#      xml = open("http://twitter.com/users/show/josemarluedke.xml")
	#    rescue OpenURI::HTTPError => e
	#        xml = false
	#    end

	#    if xml
	#      twitter = Nokogiri::XML(xml)
	#      @aaaa = twitter.xpath('/user/profile_image_url').text
	#    else
	#      @aaaa = 'error'
	#    end

		if request.GET['filterLetter']
			@contacts = Contact.my_contacts current_user, :letter => request.GET['filterLetter']
		elsif request.GET['favorite']
			@contacts = Contact.my_contacts current_user, :favorite => true
		elsif request.GET['q']
			@contacts = Contact.my_contacts current_user, :search => request.GET['q']
		elsif request.GET['filterNumber']
			@contacts = Contact.my_contacts current_user, :number => request.GET['filterNumber']
		else
			@contacts = Contact.my_contacts current_user
		end


		#@contacts = Contact.my_contacts current_user

		respond_to do |format|
			format.html # index.html.erb
			format.xml  { render :xml => @contacts }
			format.json  { render :json => @contacts }
		end
	end

	def favorite 
			@contact = Contact.find_by_id_and_user_id(params[:id], current_user.id)
			return render_404 unless @contact

			@contact.bookmark_us
			

			respond_to do |format|
				format.html {
					if request.xhr?
						render :nothing => true
					else
						redirect_to(contacts_url, :notice => "Contact was successfully #{'un' unless @contact.favorite}favorited.")
					end

				}
			end
	end

	def show
		@contact = Contact.find_by_id_and_user_id(params[:id], current_user.id)

		#Retorna 404 caso não encontre o contato
		return render_404 unless @contact

		respond_to do |format|
			format.html { render :layout => false if request.xhr? }
			format.xml  { render :xml => @contact }

		end
	end

	def new
		@contact = Contact.new

		respond_to do |format|
			format.html # new.html.erb
			format.xml  { render :xml => @contact }
		end
	end

	def edit
		@contact = Contact.find_by_id_and_user_id(params[:id], current_user.id)
		return render_404 unless @contact
	end

	def create
		@contact = Contact.new(params[:contact])
		return render_404 unless @contact

		respond_to do |format|
			if @contact.save
				format.html { redirect_to(contacts_url, :notice => 'Contact was successfully created.') }
				format.xml  { render :xml => @contact, :status => :created, :location => @contact }
			else
				format.html { render :action => "new" }
				format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
			end
		end
	end

	def update
		@contact = Contact.find_by_id_and_user_id(params[:id], current_user.id)
		return render_404 unless @contact

		respond_to do |format|
			if @contact.update_attributes(params[:contact])
				format.html { redirect_to(contacts_url, :notice => 'Contact was successfully updated.') }
				format.xml  { head :ok }
			else
				format.html { render :action => "edit" }
				format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
			end
		end
	end

	def destroy
		@contact = Contact.find_by_id_and_user_id(params[:id], current_user.id)
		return render_404 unless @contact

		@contact.destroy

		respond_to do |format|
			format.html { redirect_to(contacts_url, :notice => 'Contact was successfully deleted.') }
			format.xml  { head :ok }
		end
	end
end