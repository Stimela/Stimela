function my_models_open(desnm, modelnm)

cd([stimFolder('My_models') '\' desnm])
open_system([modelnm '_m'])
