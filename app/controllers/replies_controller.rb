class RepliesController < ApplicationController

  # POST /replies
  # POST /replies.json
  def create
    @reply = Reply.new(params[:reply])

    @reply.user = current_user

    respond_to do |format|
      if @reply.save

        TicketMailer.reply(@reply).deliver

        format.html { redirect_to @reply, notice: 'Reply was successfully created.' }
        format.json { render json: @reply, status: :created, location: @reply }
        format.js { render }
      else
        format.html { render action: "new" }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
        format.js { render }
      end
    end
  end

end
