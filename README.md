# dircom
Tcl script for comparing directories by their content.

###############################################################################
#                                                                             #
#           88  88                                                            #
#           88  ""                                                            #
#           88                                                                #
#   ,adPPYb,88  88  8b,dPPYba,   ,adPPYba,   ,adPPYba,   88,dPYba,,adPYba,    #
#  a8"    `Y88  88  88P'   "Y8  a8"     ""  a8"     "8a  88P'   "88"    "8a   #
#  8b       88  88  88          8b          8b       d8  88      88      88   #
#  "8a,   ,d88  88  88          "8a,   ,aa  "8a,   ,a8"  88      88      88   #
#   `"8bbdP"Y8  88  88           `"Ybbd8"'   `"YbbdP"'   88      88      88   #
#                                      ____ ____ ____ _ ____ _____            #
#                                     / ___/   _/  __/ /  __/__ __\           #
#                                     |    |  / |  \/| |  \/| / \             #
#                                     \___ |  \_|    | |  __/ | |             #
#                                     \____\____\_/\_\_\_/    \_/             #
#                                                                             #
#   * checksum                                                                #
#                                                                             #
#         Generate file with checksums for directory.                         #
#                                                                             #
#   * repeated                                                                #
#                                                                             #
#         Detect repeated files inside directory.                             #
#                                                                             #
#   * nrepeated                                                               #
#                                                                             #
#         Count repeated files inside directory.                              #
#                                                                             #
#   * subtract                                                                #
#                                                                             #
#         List files that are in directory A, but not in directory B.         #
#                                                                             #
#   * verify                                                                  #
#                                                                             #
#         Verify all files listed in checksums file are in the directory.     #
#                                                                             #
#                                             Programmed by Tito Hernandez.   #
#                                                                             #
###############################################################################
