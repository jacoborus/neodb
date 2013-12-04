middleware = ->

module.exports = middleware

# middleware is used for saving or updating documents
# 
# Middleware steps:
# - init
# - clean and validate
# - preprocess
# - process (save, remove, update)
# - post

