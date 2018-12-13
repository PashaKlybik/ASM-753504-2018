// LAB7.cpp : Определяет точку входа для приложения.
//

#include "stdafx.h"
#include "LAB7.h"

#define MAX_LOADSTRING 100
#define RADIUS 100
#define STIPERADIUS 30
// Глобальные переменные:
//int* forX;
//int* forY;
int forX[10];
int forY[10];
int x, y, number=0;
int capacity = 10;
void Draw(HDC, int, int);
bool needDrowing = false;
HINSTANCE hInst;                                // текущий экземпляр
WCHAR szTitle[MAX_LOADSTRING];                  // Текст строки заголовка
WCHAR szWindowClass[MAX_LOADSTRING];            // имя класса главного окна

// Отправить объявления функций, включенных в этот модуль кода:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
					 _In_opt_ HINSTANCE hPrevInstance,
					 _In_ LPWSTR    lpCmdLine,
					 _In_ int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

	// TODO: Разместите код здесь.
	//forX = (int*)malloc(capacity * sizeof(int));
	//forY = (int*)malloc(capacity * sizeof(int));
	// Инициализация глобальных строк
	LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadStringW(hInstance, IDC_LAB7, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Выполнить инициализацию приложения:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB7));

	MSG msg;

	// Цикл основного сообщения:
	while (GetMessage(&msg, nullptr, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	return (int) msg.wParam;
}



//
//  ФУНКЦИЯ: MyRegisterClass()
//
//  ЦЕЛЬ: Регистрирует класс окна.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEXW wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style          = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc    = WndProc;
	wcex.cbClsExtra     = 0;
	wcex.cbWndExtra     = 0;
	wcex.hInstance      = hInstance;
	wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB7));
	wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
	wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_LAB7);
	wcex.lpszClassName  = szWindowClass;
	wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassExW(&wcex);
}

//
//   ФУНКЦИЯ: InitInstance(HINSTANCE, int)
//
//   ЦЕЛЬ: Сохраняет маркер экземпляра и создает главное окно
//
//   КОММЕНТАРИИ:
//
//        В этой функции маркер экземпляра сохраняется в глобальной переменной, а также
//        создается и выводится главное окно программы.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Сохранить маркер экземпляра в глобальной переменной

   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
	  CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

   if (!hWnd)
   {
	  return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  ФУНКЦИЯ: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  ЦЕЛЬ: Обрабатывает сообщения в главном окне.
//
//  WM_COMMAND  - обработать меню приложения
//  WM_PAINT    - Отрисовка главного окна
//  WM_DESTROY  - отправить сообщение о выходе и вернуться
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_CREATE:
	{
		hWnd = CreateWindowEx(NULL,
			L"BUTTON",
			L"Clear",
			WS_CHILD,
			0,
			0,
			100,
			25,
			hWnd,
			HMENU(47),
			hInst,
			NULL);
		ShowWindow(hWnd, SW_SHOWNORMAL);
		break;
	}
	case WM_LBUTTONDOWN:
	{
		needDrowing = true;
		x = LOWORD(lParam);
		y = HIWORD(lParam);
		InvalidateRect(hWnd, NULL, false);
		break;
	}
	case WM_COMMAND:
		{
			int wmId = LOWORD(wParam);
			// Разобрать выбор в меню:
			switch (wmId)
			{
			case 47:
			{
				needDrowing = false;
				number = 0;
				InvalidateRect(hWnd, NULL, TRUE);
				break;
			}
			case IDM_ABOUT:
				DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
				break;
			case IDM_EXIT:
				DestroyWindow(hWnd);
				break;
			default:
				return DefWindowProc(hWnd, message, wParam, lParam);
			}
		}
		break;
	case WM_PAINT:
		{
			PAINTSTRUCT ps;
			HDC hdc = BeginPaint(hWnd, &ps);
			Draw(hdc, x, y);
			// TODO: Добавьте сюда любой код прорисовки, использующий HDC...
			EndPaint(hWnd, &ps);
		}
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

// Обработчик сообщений для окна "О программе".
INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	UNREFERENCED_PARAMETER(lParam);
	switch (message)
	{
	case WM_INITDIALOG:
		return (INT_PTR)TRUE;

	case WM_COMMAND:
		if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
		{
			EndDialog(hDlg, LOWORD(wParam));
			return (INT_PTR)TRUE;
		}
		break;
	}
	return (INT_PTR)FALSE;
}
void Draw(HDC hdc, int x, int y)
{

	HPEN hOldPen, hBlackPen;
	HBRUSH hOldBrush, hBlackBrush, hCornflowerBrush, hBrownBrush, 
					hBeigeBrush, hGreenBrush, hWhiteBrush, hCrimsonRedBrush, hLightBeigeBrush, hGreyBrush;
	hBlackPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 0));
	hBlackBrush = CreateSolidBrush(RGB(0, 0, 0));
	hCornflowerBrush = CreateSolidBrush(RGB(182, 205, 249));

	hBrownBrush = CreateSolidBrush(RGB(66, 41, 34));
	hBeigeBrush = CreateSolidBrush(RGB(231, 180, 123));

	hGreenBrush = CreateSolidBrush(RGB(0, 181, 9));
	hWhiteBrush = CreateSolidBrush(RGB(255,255,255));
	hCrimsonRedBrush = CreateSolidBrush(RGB(181, 0, 0));

	hLightBeigeBrush = CreateSolidBrush(RGB(255, 218, 179));
	hGreyBrush = CreateSolidBrush(RGB(61, 61, 61));
	hOldPen = (HPEN)SelectObject(hdc, hBlackPen);
	hOldBrush = (HBRUSH)SelectObject(hdc, hBlackBrush);
	//Если нужно нарисовать новый объект
	if (needDrowing) {
		if (x > 10 && y > 20)
		{
			number++;
			forX[number] = x;
			forY[number] = y;
			if (number == capacity) {
				capacity *= 2;
				//	forX = (int*)realloc(forX, capacity * sizeof(int));
				//	forY = (int*)realloc(forY, capacity * sizeof(int));
			}

			SelectObject(hdc, hCornflowerBrush);
			Rectangle(hdc, x, y, x + 140, y + 60);
			SelectObject(hdc, hGreenBrush);
			Rectangle(hdc, x+20, y+10, x +50, y + 20);
			SelectObject(hdc, hGreenBrush);
			Rectangle(hdc, x+10, y+40, x + 20, y + 50);
			SelectObject(hdc, hWhiteBrush);
			Rectangle(hdc, x + 20, y + 20, x + 30, y + 30);
			SelectObject(hdc, hCrimsonRedBrush);
			Rectangle(hdc, x + 20, y + 30, x + 30, y + 50);

			SelectObject(hdc, hBrownBrush);
			Rectangle(hdc, x + 50, y + 30, x + 60, y + 40);
			SelectObject(hdc, hBrownBrush);
			Rectangle(hdc, x + 70, y + 30, x + 80, y + 40);
			SelectObject(hdc, hBrownBrush);
			Rectangle(hdc, x + 60, y + 40, x + 70, y + 50);
			SelectObject(hdc, hBeigeBrush);
			Rectangle(hdc, x + 60, y + 30, x + 70, y + 40);

			SelectObject(hdc, hBlackBrush);
			Rectangle(hdc, x + 100, y + 10, x + 110, y + 20);
			SelectObject(hdc, hLightBeigeBrush);
			Rectangle(hdc, x + 100, y + 20, x + 110, y + 30);
			SelectObject(hdc, hBlackBrush);
			Rectangle(hdc, x + 100, y + 30, x + 110, y + 50);
			SelectObject(hdc, hGreyBrush);
			Rectangle(hdc, x + 120, y + 30, x + 130, y + 50);
		}
	}
	else
	{
			for (int i = 0; i < number; i++)
			{
				x = forX[i+1];
				y = forY[i+1];
				if (x > 10 && y > 20)
				{
					SelectObject(hdc, hCornflowerBrush);
					Rectangle(hdc, x, y, x + 140, y + 60);
					SelectObject(hdc, hGreenBrush);
					Rectangle(hdc, x + 20, y + 10, x + 50, y + 20);
					SelectObject(hdc, hGreenBrush);
					Rectangle(hdc, x + 10, y + 40, x + 20, y + 50);
					SelectObject(hdc, hWhiteBrush);
					Rectangle(hdc, x + 20, y + 20, x + 30, y + 30);
					SelectObject(hdc, hCrimsonRedBrush);
					Rectangle(hdc, x + 20, y + 30, x + 30, y + 50);


					SelectObject(hdc, hBrownBrush);
					Rectangle(hdc, x + 50, y + 30, x + 60, y + 40);
					SelectObject(hdc, hBrownBrush);
					Rectangle(hdc, x + 70, y + 30, x + 80, y + 40);
					SelectObject(hdc, hBrownBrush);
					Rectangle(hdc, x + 60, y + 40, x + 70, y + 50);
					SelectObject(hdc, hBeigeBrush);
					Rectangle(hdc, x + 60, y + 30, x + 70, y + 40);

					SelectObject(hdc, hBlackBrush);
					Rectangle(hdc, x + 100, y + 10, x + 110, y + 20);
					SelectObject(hdc, hLightBeigeBrush);
					Rectangle(hdc, x + 100, y + 20, x + 110, y + 30);
					SelectObject(hdc, hBlackBrush);
					Rectangle(hdc, x + 100, y + 30, x + 110, y + 50);
					SelectObject(hdc, hGreyBrush);
					Rectangle(hdc, x + 120, y + 30, x + 130, y + 50);
				}
			}
	}
	needDrowing = false;
	// Удаляем ресурсы
	SelectObject(hdc, hOldPen);
	SelectObject(hdc, hOldBrush);
	DeleteObject(hBlackPen);
	DeleteObject(hBlackBrush);
	DeleteObject(hGreenBrush);
}