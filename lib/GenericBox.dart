class GenericBox<T> {
  T obj;

  GenericBox(this.obj);

  T get value => obj;

  void set(T newObj) {
    obj = newObj;
  }

  void show() {
    print(obj);
  }
}

void main() {
  var student = [
    {'studentID': 's123456', 'fullname': 'Nguyen Thi B'},
    {'studentID': 's345672', 'fullname': 'Nguyen Van D'},
    {'studentID': 's923333', 'fullname': 'Tran Thi  Van'},
  ];

  var box = GenericBox<List<Map<String, String>>>(student);
  box.show();

  for (var s in box.obj) {
    print('${s['studentID']} - ${s['fullname']}');
  }
}
