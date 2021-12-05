# In this makefile, we've made several errors 
# Since these errors were marked as the remark, no errors will occur in this file
# If you want to see the error handling, please delete "#" notation
# Then you can see the error message
#
# Made by Super_Parser_Bros

# In here, we will make invalid rule to make target "Prof_Pandey_is_our_Idol"
#Prof_Pandey_is_our_Idol
main : lex yacc
	rm -f main
	cc lex.yy.c y.tab.c -o main -ll -lfl -g

# In here, we will make no targets error
: TA.Jo.god

lex :
	lex makefile.l
# In here, we will make error which using 8 spaces instead of tab
#        lex makefilemario.l

yacc :
	yacc makefile.y -d

# In here, we will make no rules to make target or spaces warning
#     

# Lastly, a missing separator error(which is a default error)
#  asddfasdf

