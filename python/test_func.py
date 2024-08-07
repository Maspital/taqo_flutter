from flet import Flet

@Flet.register_function
def process_data(my_string):
    return my_string*2
    