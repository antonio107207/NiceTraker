class CardSearchQuery
  IDENTIFIER_RE = /\A[A-Za-z0-9]+-\d+\z/
  MIN_LENGTH     = 2

  def initialize(query:, scope:, excluded_ids: [])
    @query        = query.to_s.strip
    @scope        = scope
    @excluded_ids = excluded_ids
  end

  def results
    return [] if @query.length < MIN_LENGTH

    base = @scope.where.not(id: @excluded_ids)

    if @query.match?(IDENTIFIER_RE)
      by_identifier(base)
    else
      by_title(base)
    end
  end

  private

  def by_identifier(base)
    key, num = @query.upcase.split("-")
    base.joins(:board).where(boards: { key: }, number: num.to_i).limit(5)
  end

  def by_title(base)
    base.where("cards.title ILIKE ?", "%#{@query}%").limit(8)
  end
end
