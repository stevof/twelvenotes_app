class UsersController < ApplicationController
	def new
	end

	def create
	  @user = User.new(user_params)
	 
	  # @user.save
	  # redirect_to @user

	  respond_to do |format|
	  	if @user.save
	  		format.html { redirect_to @user, notice: 'User was successfully created.' }
	  		format.js {}
	  		format.json { render json: @user, status: :created, location: @user }
	  	else
	  		format.html { render action: "new" }
	  		format.json { render json: @user.errors, status: :unprocessable_entity }
	  	end
	  end

	end

	def show
		@user = User.find(params[:id])
	end

	def index
		@user = User.new
		@users = User.all
	end

	def destroy
	  @user = User.find(params[:id])

	  respond_to do |format|
  		if @user.destroy
			  format.html { redirect_to users_path }
			  format.js
			else
				format.html do
					flash.now[:warning] = "Some error occurred when deleting the user."
          render :action => :edit
				end

				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end		
	end

private
  def user_params
    params.require(:user).permit(:first_name, :last_name, :user_name)
  end	
end
