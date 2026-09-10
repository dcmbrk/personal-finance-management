# personal_finance

Ứng dụng quản lý chi tiêu cá nhân (bài tập lớn môn Lập trình Flutter).

## Bài tập thực hành số 3

### Câu 1. static là gì? Cách sử dụng? Ưu nhược điểm

**static là gì?**

Trong Dart (và hầu hết các ngôn ngữ hướng đối tượng như Java, C#, C++), `static` là từ khóa dùng để khai báo một thành viên thuộc về chính lớp (class) chứ không thuộc về từng đối tượng (instance) được tạo ra từ lớp đó. Nghĩa là dù chương trình tạo ra bao nhiêu đối tượng đi nữa, thành viên `static` cũng chỉ tồn tại duy nhất một bản trong bộ nhớ và được tất cả các đối tượng dùng chung. Thành viên `static` được cấp phát ngay khi lớp được nạp vào bộ nhớ, tồn tại đến khi chương trình kết thúc, nên vòng đời của nó dài hơn vòng đời của một đối tượng thông thường. Dart hỗ trợ ba dạng: biến static (static field), phương thức static (static method) và hằng static (`static const`).

**Cách sử dụng**

Ta đặt từ khóa `static` trước khai báo biến hoặc phương thức bên trong lớp, ví dụ `static int count = 0;` hay `static double tinhTong(List<double> a) {...}`. Khi truy cập, ta gọi thông qua tên lớp chứ không qua đối tượng: `Transaction.count`, `Transaction.fromMap(...)`. Bên trong một phương thức `static` ta không được dùng `this`, cũng không truy cập trực tiếp được các biến instance, vì tại thời điểm đó có thể chưa tồn tại đối tượng nào. `static` thường được dùng cho: biến đếm số đối tượng đã tạo, hằng số cấu hình dùng chung (mã màu, tên bảng, khóa lưu trữ), các hàm tiện ích không phụ thuộc trạng thái đối tượng (định dạng tiền tệ, kiểm tra dữ liệu hợp lệ), hoặc mẫu thiết kế Singleton để giữ một thể hiện dùng chung toàn ứng dụng.

**Ưu điểm**

Tiết kiệm bộ nhớ vì chỉ có một bản duy nhất được cấp phát, không nhân lên theo số đối tượng. Truy cập nhanh và tiện lợi, không cần khởi tạo đối tượng mới. Cho phép chia sẻ dữ liệu và trạng thái chung giữa tất cả các đối tượng của lớp. Giúp nhóm các hàm tiện ích lại một chỗ, code rõ ràng và dễ tái sử dụng.

**Nhược điểm**

Vì là dữ liệu dùng chung nên `static` dễ tạo ra trạng thái toàn cục: một chỗ sửa thì mọi nơi khác bị ảnh hưởng, khó kiểm soát và khó tìm lỗi trong dự án lớn. Biến static tồn tại suốt vòng đời chương trình nên không được thu hồi bộ nhớ, dùng nhiều sẽ gây lãng phí hoặc rò rỉ bộ nhớ. Lớp lạm dụng static khó viết unit test và khó thay thế bằng đối tượng giả (mock). Phương thức static không tham gia được vào tính đa hình, không thể override theo lớp con nên làm giảm tính mở rộng của thiết kế hướng đối tượng. Ngoài ra trong môi trường đa luồng, biến static dùng chung có thể bị tranh chấp dữ liệu. Vì vậy chỉ nên dùng `static` cho hằng số, hàm tiện ích thuần túy và các trường hợp thật sự cần dùng chung.

### Câu 2. Generics Class

File: `lib/GenericBox.dart` — lớp tổng quát `GenericBox<T>` có một biến `obj` kiểu `T`, dùng để chứa và in ra danh sách sinh viên.

```
[{studentID: s123456, fullname: Nguyen Thi B}, {studentID: s345672, fullname: Nguyen Van D}, {studentID: s923333, fullname: Tran Thi  Van}]
s123456 - Nguyen Thi B
s345672 - Nguyen Van D
s923333 - Tran Thi  Van
```

Chạy: `dart run lib/GenericBox.dart`

### Câu 3. Lớp đối tượng của bài tập lớn

File: `lib/Transaction.dart` — mô tả một giao dịch thu/chi trong ứng dụng quản lý tài chính cá nhân.

Các biến:

| Biến | Kiểu | Ý nghĩa |
|---|---|---|
| `id` | String | Mã giao dịch |
| `title` | String | Tên giao dịch |
| `amount` | double | Số tiền |
| `category` | String | Danh mục (Ăn uống, Di chuyển, Lương...) |
| `date` | DateTime | Ngày phát sinh |
| `isExpense` | bool | true = chi, false = thu |
| `note` | String | Ghi chú |
| `count` | static int | Đếm số giao dịch đã tạo |

Các phương thức: `signedAmount` (số tiền có dấu), `update()` (cập nhật thông tin), `toMap()` / `fromMap()` (chuyển đổi dữ liệu), `toString()` (hiển thị).

### Câu 4. Danh sách và CRUD

File: `lib/ListTransaction.dart` — có biến `items` là `List<Transaction>`.

- `create(Transaction t)`: thêm một giao dịch vào danh sách
- `edit(String id, {...})`: sửa giao dịch theo id
- `read()`: đọc và in toàn bộ giao dịch
- `delete(String id)`: xóa giao dịch theo id
- `findById(String id)`, `balance`: tìm kiếm và tính số dư

Chạy: `dart run lib/ListTransaction.dart`

## Cấu trúc thư mục

```
lib/
├── main.dart
├── GenericBox.dart
├── Transaction.dart
└── ListTransaction.dart
```
