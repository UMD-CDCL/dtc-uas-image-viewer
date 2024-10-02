#!/usr/bin/env python3
import os
import re
import shutil
import psutil
import signal
import subprocess
import tkinter as tk
from PIL import Image, ImageTk
from tkinter import filedialog, messagebox, simpledialog, ttk
        
class ImageBrowser:

    def __init__(self, root):

        # intiialize object and hardcode values
        self.root = root
        self.image_files = []
        self.ip = "10.200.142.202"
        self.root.title("No Image")
        self.current_image_index = 0
        self.selected_directory = "/home/ctitus/Documents/dtc"

        # style everything
        style = ttk.Style()
        style.configure('TLabel', font=('Avenir', 12), padding=0)
        style.configure('TButton',
            font=('Avenir', 12),
            padding=10,
            relief='flat', 
            background='#c3c3c3',  
            foreground='black'
        )
        style.map('TButton',
            background=[('active', '#a3a3a3')],
            foreground=[('active', 'black')]
        )
        
        # shared parameters
        padx = 0
        pady = 2
        button_width = 6

        # buttons
        row = 0
        self.canvas = tk.Canvas(root, width=640, height=480)
        self.canvas.grid(row=row, column=0, columnspan=7, padx=2, pady=2)
        
        row = 1
        self.refresh_directory = ttk.Button(root, text="Record", width=button_width, command=self.record_image)
        self.refresh_directory.grid(row=row, column=0, padx=padx, pady=pady)
        
        self.refresh_directory = ttk.Button(root, text="Pull", width=button_width, command=self.pull_images)
        self.refresh_directory.grid(row=row, column=1, padx=padx, pady=pady)
        
        self.refresh_directory = ttk.Button(root, text="Load", width=button_width, command=self.load_images_from_directory)
        self.refresh_directory.grid(row=row, column=2, padx=padx, pady=pady)

        self.prev_button = ttk.Button(root, text="Prev", width=button_width, command=self.prev_image)
        self.prev_button.grid(row=row, column=3, padx=padx, pady=pady)

        self.next_button = ttk.Button(root, text="Next", width=button_width, command=self.next_image)
        self.next_button.grid(row=row, column=4, padx=padx, pady=pady)

        self.send_button = ttk.Button(root, text="Send", width=button_width, command=self.send_image)
        self.send_button.grid(row=row, column=5, padx=padx, pady=pady)

        self.send_button = ttk.Button(root, text="New", width=button_width, command=self.new_test)
        self.send_button.grid(row=row, column=6, padx=padx, pady=pady)

        self.load_images_from_directory()

        #self.select_button = ttk.Button(root, text="Select Image Directory", command=self.select_directory)
        #self.select_button.pack(side=tk.LEFT, padx=2)

        #self.separator = ttk.Label(root, text=" | ")
        #self.separator.pack(side=tk.RIGHT)

        #self.directory_label = ttk.Label(root, text="No Directory")
        #self.directory_label.pack(side=tk.RIGHT)



    #def select_directory(self):
    #    self.selected_directory = filedialog.askdirectory()
    #    self.load_images_from_directory()
        
    # runs process and makes popup to kill it (uses self.ip as arg for script)
    def run_script(self, script_name):
        process = subprocess.Popen(f"bash {self.selected_directory}/{script_name} {self.ip}", shell=True, preexec_fn=os.setpgrp)
        self.run_process(process)
                
    # creates a popup that can kill the process it's called on
    # need to set pid groups in the parent process to link children if this doesn't kill all the kids
    def run_process(self, process):
        response = messagebox.askyesno("Confirm Exit", f"Process is running. Do you want to terminate it?")
        if response:
            try:
                parent = psutil.Process(process.pid)
                if parent.children(recursive=True):
                    for child in parent.children(recursive=True):
                        child.terminate()
                    parent.terminate()
                    parent.wait(timeout=1)
            except psutil.NoSuchProcess:
                print(f"No such process with PID {pid}")
            except psutil.AccessDenied:
                print(f"Access denied to terminate process with PID {pid}")

    # calls script to record images on drone
    def record_image(self):
        self.run_script("record_image.sh")

    # 
    def pull_images(self):
        self.run_script("pull_new_images.sh")
        self.load_images_from_directory()

    def load_images_from_directory(self):
        if self.selected_directory:
            #self.directory_label.config(text="Directory: " + self.selected_directory)
            self.image_files = [f for f in os.listdir(self.selected_directory) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
            if self.image_files:
                self.current_image_index = 0
                self.show_image()

    def show_image(self):
        if self.image_files:
            image_path = os.path.join(self.selected_directory, self.image_files[self.current_image_index])
            img = Image.open(image_path)
            img.thumbnail((640, 480))
            self.tk_image = ImageTk.PhotoImage(img)
            self.canvas.create_image(0, 0, anchor=tk.NW, image=self.tk_image)
            self.root.title(self.image_files[self.current_image_index])

    def prev_image(self):
        if self.image_files:
            self.current_image_index = (self.current_image_index - 1) % len(self.image_files)
            self.show_image()

    def next_image(self):
        if self.image_files:
            self.current_image_index = (self.current_image_index + 1) % len(self.image_files)
            self.show_image()

    # TODO HANGS WHEN YOU TRY TO SEND IMAGES WHEN THERE ARE NONE
    def send_image(self):
        print("=== SEND START ===")
        if self.image_files:
            image_path = os.path.join(self.selected_directory, self.image_files[self.current_image_index])
            # TODO: If you don't want the send destination hardcoded change the destination line to this:
            # destination = simpledialog.askstring("Send Image", "Enter rsync destination (e.g. user@remote:/path/to/destination):")
            destination = "cdcl@10.200.142.103:/home/cdcl/spot/cdcl_ws/dtc/uav_images"
            if destination:
                # inplace prevent temp file, DON'T DELETE IT DUMMY
                self.run_process(subprocess.Popen(f"rsync -az --inplace --ignore-existing --progress {image_path} {destination} ; echo '=== SEND DONE ==='", shell=True))

    def new_test(self):
        self.run_script("new_test.sh")
        self.root.title("No Image")
        self.canvas.delete("all")
        self.image_files = []


if __name__ == "__main__":

    # start app
    root = tk.Tk()
    app = ImageBrowser(root)
    root.mainloop()
